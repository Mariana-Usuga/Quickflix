import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickflix/core/router/app_router.dart';
import 'package:quickflix/models/video_post.dart';
import 'package:quickflix/features/widgets/video/fullscreen_player.dart';

class VideoThumbnailCard extends StatefulWidget {
  final VideoPost video;
  final bool showEpisodeInfo;

  const VideoThumbnailCard({
    super.key,
    required this.video,
    this.showEpisodeInfo = false,
  });

  @override
  State<VideoThumbnailCard> createState() => _VideoThumbnailCardState();
}

class _VideoThumbnailCardState extends State<VideoThumbnailCard> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de scroll vertical
        //context.push(AppRouter.discover);
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
                    // Mostrar logo si hay error, sino mostrar el video
                    if (_hasError)
                      Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                      )
                    else
                      FullScreenPlayer(
                        videoUrl: widget.video.videoUrl,
                        caption: widget.video.caption,
                        onError: () {
                          if (mounted) {
                            setState(() {
                              _hasError = true;
                            });
                          }
                        },
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
              widget.video.caption,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.showEpisodeInfo) ...[
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
