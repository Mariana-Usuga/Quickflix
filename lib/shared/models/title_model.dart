import 'package:quickflix/shared/entities/video_title.dart';

class TitleModel extends VideoTitle {
  TitleModel({
    required super.id,
    required super.caption, // Mapeamos el 'name' del JSON a 'caption' de la entidad
    required super.videoUrl,
    required super.imageUrl,
    super.likes = 0,
    super.views = 0,
    required super.gender,
    required super.numberOfSeasons,
    required super.synopsis,
    required super.rating,
    required super.releaseDate,
  });

  factory TitleModel.fromJson(Map<String, dynamic> json) {
    // Mapear campos de Supabase: title -> name, play_black_id -> videoUrl
    final int id = json['id'] ?? 0;
    final String title = json['title'] ?? json['name'] ?? 'no name';
    final String? playBlackId = json['play_black_id'] as String?;
    final String? playbackId = json['playback_id'] as String?;
    final String? videoUrl = json['videoUrl'] as String?;
    final String? imageUrl = json['url_image'] as String?;
    final String? gender = json['gender'] as String?;
    final int? numberOfSeasons = json['number_of_seasons'] as int?;
    final String? synopsis = json['synopsis'] as String?;
    final double? rating = json['rating'] as double?;
    final String? releaseDate = json['release_date'] as String?;

    return TitleModel(
      id: id,
      caption: title,
      videoUrl: videoUrl ?? _buildMuxVideoUrl(playBlackId ?? playbackId),
      imageUrl: _buildImageUrl(imageUrl),
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
      gender: gender ?? '',
      numberOfSeasons: numberOfSeasons ?? 0,
      synopsis: synopsis ?? '',
      rating: rating ?? 0,
      releaseDate: releaseDate ?? '',
    );
  }

  // Método helper para construir la URL de Mux desde el playback_id
  static String _buildMuxVideoUrl(dynamic playbackId) {
    if (playbackId == null || playbackId.toString().isEmpty) {
      return '';
    }
    // Construir URL de Mux HLS
    //https://stream.mux.com/005Rj02giEiz6vQZ9jJPTsDtK3KwKz00uoaPPHrUYgXppU.m3u8
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
        'name': caption,
        'videoUrl': videoUrl,
        'imageUrl': imageUrl,
        'likes': likes,
        'views': views,
      };

  VideoTitle toVideoPostEntity() => VideoTitle(
        id: id,
        caption: caption,
        videoUrl: videoUrl,
        imageUrl: imageUrl,
        likes: likes,
        views: views,
        gender: gender,
        numberOfSeasons: numberOfSeasons,
        synopsis: synopsis,
        rating: rating,
        releaseDate: releaseDate,
      );
}
