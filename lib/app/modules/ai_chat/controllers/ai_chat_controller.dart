import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/data/models/chat.dart';

class AiChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isAiThinking = false.obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<String> suggestions = [
    'Konsep rumah minimalis modern 2 lantai',
    'Estimasi biaya bangun rumah tipe 36',
    'Rekomendasi gaya interior lahan sempit',
    'Berapa lama proyek desain arsitektur?',
  ];

  @override
  void onInit() {
    super.onInit();
    // Add initial greeting message
    messages.add(_createMessage(
      text: 'Halo! Saya Sitek AI, asisten arsitektur digital Anda. Ada yang bisa saya bantu hari ini mengenai desain rumah impian atau estimasi biaya konstruksi?',
      isMine: false,
    ));
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void goBack() {
    Get.back();
  }

  ChatMessage _createMessage({required String text, required bool isMine}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: 'ai_conversation',
      userId: isMine ? 'user' : 'sitek_ai',
      body: text,
      content: text,
      role: isMine ? 'user' : 'model',
      type: 'text',
      attachment: null,
      readAt: DateTime.now(),
      isMine: isMine,
      sender: isMine
          ? const ChatSender(id: 'user', name: 'User', email: 'user@halositek.com')
          : const ChatSender(id: 'sitek_ai', name: 'Sitek AI', email: 'ai@halositek.com'),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void selectSuggestion(String suggestion) {
    if (isAiThinking.value) return;
    sendMessage(customText: suggestion);
  }

  Future<void> sendMessage({String? customText}) async {
    if (isAiThinking.value) return;

    final text = customText ?? messageController.text.trim();
    if (text.isEmpty) return;

    if (customText == null) {
      messageController.clear();
    }

    // Add user message
    messages.add(_createMessage(text: text, isMine: true));
    _scrollToBottom();

    // Trigger AI thinking animation
    isAiThinking.value = true;
    _scrollToBottom();

    // Simulate network/AI computation delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Generate response
    final responseText = _generateResponse(text);
    messages.add(_createMessage(text: responseText, isMine: false));
    isAiThinking.value = false;
    _scrollToBottom();
  }

  String _generateResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('minimalis')) {
      return 'Konsep rumah minimalis modern sangat mengedepankan efisiensi ruang dan estetika yang bersih. Berikut beberapa aspek pentingnya:\n\n'
          '• **Open Plan Layout**: Hubungkan ruang keluarga, ruang makan, dan pantry tanpa sekat tebal agar terasa lebih luas.\n'
          '• **Skema Warna Netral**: Gunakan kombinasi warna putih, abu-abu muda, dan aksen kayu alami untuk kehangatan.\n'
          '• **Fasad Kaca & Bukaan Besar**: Memaksimalkan pencahayaan alami untuk mengurangi penggunaan listrik di siang hari.\n\n'
          'Anda dapat menjelajahi lebih banyak desain minimalis rancangan arsitek kami di tab **Design Gallery** pada menu utama.';
    } else if (q.contains('biaya') || q.contains('harga') || q.contains('estimasi') || q.contains('hitung') || q.contains('budget')) {
      return 'Estimasi biaya pembangunan rumah sangat bergantung pada lokasi proyek, spesifikasi material bangunan, dan kompleksitas desain arsitektur.\n\n'
          'Secara umum, perkiraan acuan kasar biaya konstruksi per meter persegi (m²) adalah:\n'
          '• **Standar Sederhana**: ± Rp 4.500.000 - Rp 5.500.000 / m²\n'
          '• **Menengah / Modern**: ± Rp 6.000.000 - Rp 7.500.000 / m²\n'
          '• **Premium / Mewah**: ± Rp 8.000.000 - Rp 10.000.000+ / m²\n\n'
          '*Simulasi*: Membangun rumah tipe 36 dengan kualitas menengah (misal Rp 6.000.000/m²) membutuhkan estimasi biaya fisik bangunan sekitar **Rp 216.000.000** (belum termasuk harga tanah, perizinan, dan jasa arsitek).';
    } else if (q.contains('gaya') || q.contains('desain') || q.contains('interior') || q.contains('konsep')) {
      return 'Di Halositek, arsitek-arsitek kami berpengalaman dalam merancang berbagai gaya arsitektur dan interior populer:\n\n'
          '1. **Japandi (Japanese-Scandinavian)**: Menggabungkan kenyamanan fungsional ala Skandinavia dengan estetika ketenangan Jepang.\n'
          '2. **Modern Classic**: Mengombinasikan detail profil dinding klasik dengan furnitur minimalis modern yang elegan.\n'
          '3. **Industrial**: Menonjolkan material mentah terekspos seperti dinding bata merah, beton poles, semen ekspos, dan rangka besi hitam.\n'
          '4. **Tropical Modern**: Menghadirkan ventilasi silang yang baik, teritisan lebar, dan vegetasi hijau subur yang cocok untuk iklim tropis Indonesia.\n\n'
          'Ingin melihat contoh nyatanya? Anda bisa membuka profil lengkap arsitek kami di tab **Architect**.';
    } else if (q.contains('waktu') || q.contains('durasi') || q.contains('lama') || q.contains('proyek') || q.contains('proses')) {
      return 'Timeline pembuatan desain arsitektur umumnya berkisar antara **4 hingga 8 minggu**, yang terbagi dalam beberapa tahap berikut:\n\n'
          '• **Tahap Konsep (1-2 minggu)**: Diskusi keinginan klien, pembuatan zonasi ruangan, dan penentuan konsep dasar (moodboard).\n'
          '• **Tahap Visualisasi 3D (2-3 minggu)**: Pembuatan visualisasi 3D eksterior dan interior beserta detail pencahayaan.\n'
          '• **Pembuatan DED / Gambar Kerja (2-3 minggu)**: Penyusunan gambar detail arsitektur, struktur, serta sistem mekanikal, elektrikal, dan plumbing (MEP) untuk keperluan kontraktor lapangan.\n\n'
          'Waktu ini bisa bervariasi bergantung pada kecepatan komunikasi dan jumlah revisi yang diajukan.';
    } else if (q.contains('halo') || q.contains('hi') || q.contains('pagi') || q.contains('siang') || q.contains('sore') || q.contains('malam') || q.contains('tanya') || q.contains('permisi')) {
      return 'Halo! Saya siap membantu menjawab pertanyaan Anda seputar arsitektur, tips desain, perkiraan biaya renovasi, atau cara memesan jasa arsitek di Halositek. Apa yang ingin Anda tanyakan hari ini?';
    }

    return 'Terima kasih atas pertanyaannya! Sebagai asisten digital, saya dapat membagikan informasi dasar arsitektur. Namun, untuk hasil desain yang akurat, berlisensi, dan disesuaikan dengan kebutuhan lahan Anda, saya sarankan Anda langsung berkonsultasi dengan mitra arsitek kami.\n\n'
        'Anda dapat melihat detail portofolio, review, serta mengirimkan pesan langsung kepada arsitek pilihan Anda melalui tab **Architect** di menu utama aplikasi Halositek.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
