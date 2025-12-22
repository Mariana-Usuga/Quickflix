import 'package:quickflix/models/video_post.dart';

class LocalVideoModel {
  final String name;
  final String videoUrl;
  final String imageUrl;
  final int likes;
  final int views;
  final String gender;
  final int numberOfSeasons;
  final String synopsis;

  LocalVideoModel({
    //este es el constructor
    required this.name,
    required this.videoUrl,
    required this.imageUrl,
    this.likes = 0,
    this.views = 0,
    required this.gender,
    required this.numberOfSeasons,
    required this.synopsis,
  });

  factory LocalVideoModel.fromJson(Map<String, dynamic> json) {
    // Mapear campos de Supabase: title -> name, play_black_id -> videoUrl
    final String title = json['title'] ?? json['name'] ?? 'no name';
    final String? playBlackId = json['play_black_id'] as String?;
    final String? playbackId = json['playback_id'] as String?;
    final String? videoUrl = json['videoUrl'] as String?;
    final String? imageUrl = json['url_image'] as String?;
    final String? gender = json['gender'] as String?;
    final int? numberOfSeasons = json['number_of_seasons'] as int?;
    final String? synopsis = json['synopsis'] as String?;

    return LocalVideoModel(
      name: title,
      videoUrl: videoUrl ?? _buildMuxVideoUrl(playBlackId ?? playbackId),
      imageUrl: _buildImageUrl(imageUrl),
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
      gender: gender ?? '',
      numberOfSeasons: numberOfSeasons ?? 0,
      synopsis: synopsis ?? '',
    );
  }

  // Método helper para construir la URL de Mux desde el playback_id
  static String _buildMuxVideoUrl(dynamic playbackId) {
    if (playbackId == null || playbackId.toString().isEmpty) {
      return '';
    }
    // Construir URL de Mux HLS
    return 'https://stream.mux.com/$playbackId.m3u8';
  }

  static String _buildImageUrl(dynamic nameItem) {
    if (nameItem == null || nameItem.toString().isEmpty) {
      return '';
    }
    // Construir URL de Mux HLS
    return 'https://nnvfgqkklvbsukpabbcy.supabase.co/storage/v1/object/public/images/Quickflix/$nameItem.png';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'videoUrl': videoUrl,
        'imageUrl': imageUrl,
        'likes': likes,
        'views': views,
      };

  VideoPost toVideoPostEntity() => VideoPost(
        id: '',
        caption: name,
        videoUrl: videoUrl,
        imageUrl: imageUrl,
        likes: likes,
        views: views,
        gender: gender,
        numberOfSeasons: numberOfSeasons,
        synopsis: synopsis,
      );
}
