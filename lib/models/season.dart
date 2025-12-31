class Season {
  final int id;
  final DateTime createdAt;
  final int titleId;
  final String name;
  final String? posterUrl;
  final int seasonNumber;

  const Season({
    required this.id,
    required this.createdAt,
    required this.titleId,
    required this.name,
    this.posterUrl,
    required this.seasonNumber,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    // Parsear created_at
    DateTime? createdAt;
    if (json['created_at'] != null) {
      if (json['created_at'] is String) {
        createdAt = DateTime.tryParse(json['created_at']);
      } else if (json['created_at'] is DateTime) {
        createdAt = json['created_at'] as DateTime;
      }
    }
    createdAt ??= DateTime.now();

    return Season(
      id: json['id'] as int? ?? 0,
      createdAt: createdAt,
      titleId: json['title_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      posterUrl: json['poster_url'] as String?,
      seasonNumber: json['season_number'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'title_id': titleId,
        'name': name,
        'poster_url': posterUrl,
        'season_number': seasonNumber,
      };
}

