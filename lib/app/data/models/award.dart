class Award {
  final String id;
  final String title;
  final String imageUrl;
  final String dateLabel;

  const Award({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.dateLabel,
  });

  factory Award.fromJson(Map<String, dynamic> json) {
    return Award(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['thumbnail'] ?? '').toString(),
      dateLabel: (json['date'] ?? json['year'] ?? '').toString(),
    );
  }

  factory Award.dummy() {
    return const Award(
      id: '',
      title: 'Loading...',
      imageUrl: '',
      dateLabel: '',
    );
  }
}
