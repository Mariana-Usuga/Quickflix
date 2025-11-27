import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mux_videos_app/config/routes/app_router.dart';
import 'package:mux_videos_app/domain/entities/video_post.dart';
import 'package:mux_videos_app/presentation/widgets/video/fullscreen_player.dart';

class VideoThumbnailCard extends StatelessWidget {
  final VideoPost video;
  final bool showEpisodeInfo;

  const VideoThumbnailCard({
    super.key,
    required this.video,
    this.showEpisodeInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de scroll vertical
        context.push(AppRouter.discover);
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail del video
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Usar el video como thumbnail (pausado)
                    FullScreenPlayer(
                      videoUrl: video.videoUrl,
                      caption: video.caption,
                    ),
                    // Overlay oscuro
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Play button overlay
                    const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Título
            Text(
              video.caption,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showEpisodeInfo) ...[
              const SizedBox(height: 4),
              Text(
                'EP: 10/42',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

