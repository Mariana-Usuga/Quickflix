class Episode {
  final int id;
  final DateTime createdAt;
  final int titleId;
  final int episodeNumber;
  final int priceCoins;
  final String playBlackId;
  final String episodeUrl;

  const Episode({
    required this.id,
    required this.createdAt,
    required this.titleId,
    required this.episodeNumber,
    required this.priceCoins,
    required this.playBlackId,
    required this.episodeUrl,
  });
}
