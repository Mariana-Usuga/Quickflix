class VideoPost {
  final String id;
  final String caption;
  final String videoUrl;
  final String imageUrl;
  final int likes;
  final int views;
  final String gender;
  final int numberOfSeasons;

  VideoPost({
    required this.id,
    required this.caption,
    required this.videoUrl,
    required this.imageUrl,
    this.likes = 0,
    this.views = 0,
    required this.gender,
    required this.numberOfSeasons,
  });
}
