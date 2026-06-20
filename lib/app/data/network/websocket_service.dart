import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_client.dart';
import 'token_service.dart';

/// A singleton GetxService that manages a WebSocket connection using the
/// Pusher protocol (compatible with Laravel Reverb).
///
/// Usage:
/// ```dart
/// final ws = Get.find<WebSocketService>();
/// await ws.connect();
/// await ws.subscribe('private-chat.conversation.$id');
/// ws.on('private-chat.conversation.$id', 'chat.message.sent', (data) { ... });
/// ```
class WebSocketService extends GetxService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final isConnected = false.obs;

  String? _socketId;
  String? get socketId => _socketId;

  // ── Reconnect state ─────────────────────────────────────────────────
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectDelay = 30; // seconds
  bool _intentionalDisconnect = false;

  // ── Ping/pong keep-alive ────────────────────────────────────────────
  Timer? _pingTimer;

  // ── Event listeners ─────────────────────────────────────────────────
  // key: "$channel::$event"
  final Map<String, List<void Function(Map<String, dynamic>)>> _listeners = {};

  // ── Channel tracking ────────────────────────────────────────────────
  final Set<String> _subscribedChannels = {};

  // ── Pending subscriptions (waiting for connection) ──────────────────
  final Set<String> _pendingSubscriptions = {};

  // ── Config ──────────────────────────────────────────────────────────
  String get _wsBaseUrl => dotenv.env['WEB_SOCKET_BASE_URL'] ?? '';
  String get _appKey => dotenv.env['WEB_SOCKET_APP_KEY'] ?? '';

  // ────────────────────────────────────────────────────────────────────
  //  CONNECTION
  // ────────────────────────────────────────────────────────────────────

  /// Establishes the WebSocket connection.
  ///
  /// Automatically converts `http(s)` URLs to `ws(s)` and appends the
  /// Pusher-protocol app endpoint `/app/{APP_KEY}`.
  Future<void> connect() async {
    if (_channel != null) return; // already connected or connecting

    _intentionalDisconnect = false;

    final wsUrl = _buildWsUrl();
    if (wsUrl == null) {
      debugPrint('[WS] ❌ Cannot connect – WEB_SOCKET_BASE_URL or WEB_SOCKET_APP_KEY is missing');
      return;
    }

    debugPrint('[WS] 🔌 Connecting to $wsUrl');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _channel!.ready;

      _subscription = _channel!.stream.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: _onError,
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[WS] ❌ Connection failed: $e');
      _channel = null;
      _scheduleReconnect();
    }
  }

  /// Gracefully disconnects and cleans up resources.
  void disconnect() {
    _intentionalDisconnect = true;
    _cleanup();
  }

  /// Subscribe to a Pusher channel. For `private-*` channels the auth
  /// endpoint is called automatically.
  Future<void> subscribe(String channel) async {
    if (_subscribedChannels.contains(channel)) return;

    // If we're not connected yet, queue the subscription for later.
    if (_socketId == null || _channel == null) {
      _pendingSubscriptions.add(channel);
      return;
    }

    try {
      Map<String, dynamic> data = {'channel': channel};

      if (channel.startsWith('private-') || channel.startsWith('presence-')) {
        final auth = await _authenticate(channel);
        if (auth == null) {
          debugPrint('[WS] ❌ Auth failed for $channel');
          return;
        }
        data['auth'] = auth;
      }

      _send({'event': 'pusher:subscribe', 'data': data});
      _subscribedChannels.add(channel);
      debugPrint('[WS] 📡 Subscribed to $channel');
    } catch (e) {
      debugPrint('[WS] ❌ Subscribe error for $channel: $e');
    }
  }

  /// Unsubscribe from a channel and remove all related listeners.
  void unsubscribe(String channel) {
    _pendingSubscriptions.remove(channel);

    if (!_subscribedChannels.contains(channel)) return;

    _send({
      'event': 'pusher:unsubscribe',
      'data': {'channel': channel},
    });

    _subscribedChannels.remove(channel);

    // Remove all listeners for this channel
    _listeners.removeWhere((key, _) => key.startsWith('$channel::'));

    debugPrint('[WS] 🔕 Unsubscribed from $channel');
  }

  /// Register a listener for a specific channel + event combination.
  void on(String channel, String event, void Function(Map<String, dynamic>) callback) {
    final key = '$channel::$event';
    _listeners.putIfAbsent(key, () => []).add(callback);
  }

  /// Remove a specific listener for a channel + event combination.
  void off(String channel, String event, [void Function(Map<String, dynamic>)? callback]) {
    final key = '$channel::$event';
    if (callback != null) {
      _listeners[key]?.remove(callback);
      if (_listeners[key]?.isEmpty ?? false) _listeners.remove(key);
    } else {
      _listeners.remove(key);
    }
  }

  /// Remove ALL listeners for a given channel (all events).
  void offChannel(String channel) {
    _listeners.removeWhere((key, _) => key.startsWith('$channel::'));
  }

  // ────────────────────────────────────────────────────────────────────
  //  LIFECYCLE (GetxService)
  // ────────────────────────────────────────────────────────────────────

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }

  // ────────────────────────────────────────────────────────────────────
  //  PRIVATE – message handling
  // ────────────────────────────────────────────────────────────────────

  void _onMessage(dynamic raw) {
    try {
      final frame = jsonDecode(raw as String) as Map<String, dynamic>;
      final event = frame['event'] as String? ?? '';

      switch (event) {
        case 'pusher:connection_established':
          _handleConnectionEstablished(frame);
          break;
        case 'pusher:ping':
          _send({'event': 'pusher:pong', 'data': {}});
          break;
        case 'pusher:pong':
          // ignore
          break;
        case 'pusher:error':
          debugPrint('[WS] ⚠️ Pusher error: ${frame['data']}');
          break;
        case 'pusher_internal:subscription_succeeded':
          debugPrint('[WS] ✅ Subscription succeeded: ${frame['channel']}');
          break;
        default:
          _dispatchEvent(frame);
      }
    } catch (e) {
      debugPrint('[WS] ❌ Failed to parse message: $e');
    }
  }

  void _handleConnectionEstablished(Map<String, dynamic> frame) {
    final data = _parseData(frame['data']);
    _socketId = data['socket_id']?.toString();
    isConnected.value = true;
    _reconnectAttempts = 0;

    debugPrint('[WS] ✅ Connected – socket_id: $_socketId');

    // Start keep-alive ping
    _startPingTimer();

    // Process any queued subscriptions
    _processPendingSubscriptions();
  }

  void _dispatchEvent(Map<String, dynamic> frame) {
    final channel = frame['channel'] as String? ?? '';
    final event = frame['event'] as String? ?? '';
    final data = _parseData(frame['data']);

    final key = '$channel::$event';
    final callbacks = _listeners[key];

    if (callbacks != null && callbacks.isNotEmpty) {
      for (final cb in List.from(callbacks)) {
        try {
          cb(data);
        } catch (e) {
          debugPrint('[WS] ❌ Listener error for $key: $e');
        }
      }
    }
  }

  Map<String, dynamic> _parseData(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      try {
        final parsed = jsonDecode(raw);
        if (parsed is Map) return Map<String, dynamic>.from(parsed);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  // ────────────────────────────────────────────────────────────────────
  //  PRIVATE – auth
  // ────────────────────────────────────────────────────────────────────

  Future<String?> _authenticate(String channel) async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.private.post(
        '/broadcasting/auth',
        data: {
          'channel_name': channel,
          'socket_id': _socketId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['auth']?.toString();
      }
    } catch (e) {
      debugPrint('[WS] ❌ Auth request failed: $e');
    }
    return null;
  }

  // ────────────────────────────────────────────────────────────────────
  //  PRIVATE – helpers
  // ────────────────────────────────────────────────────────────────────

  String? _buildWsUrl() {
    if (_wsBaseUrl.isEmpty || _appKey.isEmpty) return null;

    String base = _wsBaseUrl;

    // Auto-detect protocol: http→ws, https→wss
    if (base.startsWith('https://')) {
      base = 'wss://${base.substring(8)}';
    } else if (base.startsWith('http://')) {
      base = 'ws://${base.substring(7)}';
    } else if (!base.startsWith('ws://') && !base.startsWith('wss://')) {
      base = 'ws://$base';
    }

    // Remove trailing slash
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);

    return '$base/app/$_appKey';
  }

  void _send(Map<String, dynamic> payload) {
    try {
      _channel?.sink.add(jsonEncode(payload));
    } catch (e) {
      debugPrint('[WS] ❌ Send error: $e');
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    // Send ping every 30s to keep connection alive
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (isConnected.value) {
        _send({'event': 'pusher:ping', 'data': {}});
      }
    });
  }

  Future<void> _processPendingSubscriptions() async {
    final pending = Set<String>.from(_pendingSubscriptions);
    _pendingSubscriptions.clear();
    for (final channel in pending) {
      await subscribe(channel);
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  PRIVATE – reconnect
  // ────────────────────────────────────────────────────────────────────

  void _onDisconnected() {
    debugPrint('[WS] 🔌 Disconnected');
    _onConnectionLost();
  }

  void _onError(dynamic error) {
    debugPrint('[WS] ❌ Error: $error');
    _onConnectionLost();
  }

  void _onConnectionLost() {
    isConnected.value = false;
    _socketId = null;
    _pingTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;

    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;

    // Move all subscribed channels to pending so they are re-subscribed on
    // reconnect.
    _pendingSubscriptions.addAll(_subscribedChannels);
    _subscribedChannels.clear();

    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    // Exponential backoff: 2, 4, 8, 16, 30 (capped)
    final delay = _reconnectAttempts <= 1
        ? 2
        : (_maxReconnectDelay < (1 << _reconnectAttempts) ? _maxReconnectDelay : (1 << _reconnectAttempts));

    debugPrint('[WS] 🔄 Reconnecting in ${delay}s (attempt $_reconnectAttempts)');

    _reconnectTimer = Timer(Duration(seconds: delay), () async {
      await connect();
    });
  }

  void _cleanup() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _subscribedChannels.clear();
    _pendingSubscriptions.clear();
    _listeners.clear();
    isConnected.value = false;
    _socketId = null;

    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }
}
