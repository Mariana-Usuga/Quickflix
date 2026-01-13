class VideoTitle {
  final int id;
  final String caption;
  final String videoUrl;
  final String imageUrl;
  final int likes;
  final int views;
  final String gender;
  final int numberOfSeasons;
  final String synopsis;
  final double rating;
  final String releaseDate;

  VideoTitle({
    required this.id,
    required this.caption,
    required this.videoUrl,
    required this.imageUrl,
    this.likes = 0,
    this.views = 0,
    required this.gender,
    required this.numberOfSeasons,
    required this.synopsis,
    this.rating = 0,
    required this.releaseDate,
  });
}
