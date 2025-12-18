import 'package:quickflix/models/video_post.dart';

class LocalVideoModel {
  final String name;
  final String videoUrl;
  final int likes;
  final int views;


  LocalVideoModel({
    //este es el constructor
    required this.name,
    required this.videoUrl,
    this.likes = 0,
    this.views= 0,
  });

  factory LocalVideoModel.fromJson(Map<String, dynamic> json) {
    // Mapear campos de Supabase: title -> name, play_black_id -> videoUrl
    final String title = json['title'] ?? json['name'] ?? 'no name';
    final String? playBlackId = json['play_black_id'] as String?;
    final String? playbackId = json['playback_id'] as String?;
    final String? videoUrl = json['videoUrl'] as String?;
    
    return LocalVideoModel(
      name: title,
      videoUrl: videoUrl ?? _buildMuxVideoUrl(playBlackId ?? playbackId),
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
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


  Map<String, dynamic> toJson() => {
        'name': name,
        'videoUrl': videoUrl,
        'likes': likes,
        'views': views,
      };

  VideoPost toVideoPostEntity() => VideoPost(
        caption: name,
        videoUrl: videoUrl,
        likes: likes,
        views: views,
        
      );
}

