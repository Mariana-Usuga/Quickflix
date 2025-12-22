import 'package:flutter/material.dart';
import 'package:quickflix/models/video_post.dart';

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),

          // Etiquetas y vistas
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTag('New'),
                const SizedBox(width: 6),
                _buildTag(video.gender),
                const SizedBox(width: 6),
                _buildTag('50.7M'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Descripción
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(
              video.synopsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 12),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A), // Fondo #2A2A2A
        borderRadius: BorderRadius.circular(5),
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
