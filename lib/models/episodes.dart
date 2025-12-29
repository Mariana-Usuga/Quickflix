class Episode {
  final int id;
  final DateTime createdAt;
  final int titleId;
  final int episodeNumber;
  final int priceCoins;
  final String playBlackId;

  const Episode({
    required this.id,
    required this.createdAt,
    required this.titleId,
    required this.episodeNumber,
    required this.priceCoins,
    required this.playBlackId,
  });

  /// From Supabase / JSON
  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at']),
      titleId: json['title_id'] as int,
      episodeNumber: json['episode_number'] as int,
      priceCoins: json['price_coins'] as int,
      playBlackId: json['play_black_id'] as String,
    );
  }

  /// To JSON (para inserts/updates)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'title_id': titleId,
      'episode_number': episodeNumber,
      'price_coins': priceCoins,
      'play_black_id': playBlackId,
    };
  }
}
