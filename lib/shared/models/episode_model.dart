import 'package:quickflix/shared/entities/episode.dart';

class EpisodeModel extends Episode {
  EpisodeModel({
    required super.id,
    required super.createdAt,
    required super.titleId,
    required super.episodeNumber,
    required super.priceCoins,
    required super.playBlackId,
    required super.episodeUrl,
    super.seasonId,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
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

    return EpisodeModel(
      id: json['id'] as int? ?? 0,
      createdAt: createdAt,
      titleId: json['title_id'] as int? ?? 0,
      episodeNumber: json['episode_number'] as int? ?? 0,
      priceCoins: json['price_coins'] as int? ?? 0,
      playBlackId: json['play_black_id'] as String? ?? '',
      episodeUrl: _buildMuxVideoUrl(json['play_black_id']),
      seasonId: json['season_id'] as int?,
    );
  }

  static String _buildMuxVideoUrl(dynamic playbackId) {
    if (playbackId == null || playbackId.toString().isEmpty) {
      return '';
    }
    // Construir URL de Mux HLS
    //https://stream.mux.com/005Rj02giEiz6vQZ9jJPTsDtK3KwKz00uoaPPHrUYgXppU.m3u8
    return 'https://stream.mux.com/$playbackId.m3u8';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'title_id': titleId,
        'episode_number': episodeNumber,
        'price_coins': priceCoins,
        'play_black_id': playBlackId,
      };

  Episode toEpisodeEntity() => Episode(
        id: id,
        createdAt: createdAt,
        titleId: titleId,
        episodeNumber: episodeNumber,
        priceCoins: priceCoins,
        playBlackId: playBlackId,
        episodeUrl: episodeUrl,
        seasonId: seasonId,
      );
}
