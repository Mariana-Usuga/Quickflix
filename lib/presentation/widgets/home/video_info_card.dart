import 'package:flutter/material.dart';
import 'package:mux_videos_app/domain/entities/video_post.dart';
import 'package:mux_videos_app/config/helpers/text_formatter.dart';

class VideoInfoCard extends StatelessWidget {
  final VideoPost video;
  final int currentIndex;
  final int totalVideos;
  final VoidCallback? onPlayPressed;

  const VideoInfoCard({
    super.key,
    required this.video,
    required this.currentIndex,
    required this.totalVideos,
    this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombres de actores (simulado - puedes obtenerlo de la entidad si lo agregas)
          const Text(
            'Lily Collins • Sam Claflin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          // Título del video
          Text(
            video.caption,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Etiquetas y vistas
          Row(
            children: [
              _buildTag('New'),
              const SizedBox(width: 6),
              _buildTag('Romance'),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${TextFormatter.textReadeableNumber(video.views.toDouble())}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Descripción
          Text(
            'Two souls find solace in each other, unaware of the looming shadows threatening their newfound happiness. Will their love endure?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Botón Play
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPlayPressed ?? () {
                // Default action si no se proporciona callback
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'Play',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Indicadores de paginación
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalVideos > 5 ? 5 : totalVideos,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: index == (currentIndex % 5) ? 28 : 18,
                height: 3,
                decoration: BoxDecoration(
                  color: index == (currentIndex % 5)
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

