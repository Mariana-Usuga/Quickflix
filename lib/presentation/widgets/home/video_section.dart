import 'package:flutter/material.dart';
import 'package:mux_videos_app/domain/entities/video_post.dart';
import 'package:mux_videos_app/presentation/widgets/home/video_thumbnail_card.dart';

class VideoSection extends StatelessWidget {
  final String title;
  final List<VideoPost> videos;
  final bool showEpisodeInfo;

  const VideoSection({
    super.key,
    required this.title,
    required this.videos,
    this.showEpisodeInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: VideoThumbnailCard(
                  video: videos[index],
                  showEpisodeInfo: showEpisodeInfo,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

