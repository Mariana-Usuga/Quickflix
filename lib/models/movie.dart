class Movie {
  final String isarId; // you can also use id = null to auto increment
  final bool adult;
  final String backdropPath;
  final List<String> genreIds;
  final int id;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String posterPath;
  final DateTime releaseDate;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;

  const Movie(
      {required this.adult,
      required this.backdropPath,
      required this.genreIds,
      required this.id,
      required this.originalLanguage,
      required this.originalTitle,
      required this.overview,
      required this.popularity,
      required this.posterPath,
      required this.releaseDate,
      required this.title,
      required this.video,
      required this.voteAverage,
      required this.voteCount,
      required this.isarId});

  // Factory method to create Movie from content_analysis table data
  factory Movie.fromContentAnalysis(Map<String, dynamic> json) {
    // Parse created_at to DateTime
    DateTime? releaseDate;
    if (json['created_at'] != null) {
      if (json['created_at'] is String) {
        releaseDate = DateTime.tryParse(json['created_at']);
      } else if (json['created_at'] is DateTime) {
        releaseDate = json['created_at'] as DateTime;
      }
    }
    releaseDate ??= DateTime.now();

    // Get title from content_analysis
    final title = json['title'] ?? 'Sin título';

    // Build posterPath from play_black_id if available (Mux thumbnail)
    String posterPath = '';
    final playBlackId = json['play_black_id'] as String?;
    if (playBlackId != null && playBlackId.isNotEmpty) {
      // Mux thumbnail URL pattern
      posterPath = 'https://image.mux.com/$playBlackId/thumbnail.jpg';
    }

    return Movie(
      isarId: json['id']?.toString() ?? '',
      adult: false,
      backdropPath: posterPath,
      genreIds: const [],
      id: json['id'] as int? ?? 0,
      originalLanguage: 'es',
      originalTitle: title,
      overview: '', // content_analysis doesn't have overview
      popularity: 0.0,
      posterPath: posterPath,
      releaseDate: releaseDate,
      title: title,
      video: true,
      voteAverage: 0.0, // content_analysis doesn't have vote average
      voteCount: 0,
    );
  }
}
