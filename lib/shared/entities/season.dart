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
}
