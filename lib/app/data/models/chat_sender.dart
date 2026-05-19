class ChatSender {
  final String id;
  final String name;
  final String email;

  const ChatSender({required this.id, required this.name, required this.email});

  factory ChatSender.fromJson(Map<String, dynamic> json) {
    return ChatSender(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}
