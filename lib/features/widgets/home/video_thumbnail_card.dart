import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickflix/models/video_post.dart';

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
  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* Imagen
          SizedBox(
            width: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                widget.video.imageUrl,
                fit: BoxFit.cover,
                width: 150,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  return GestureDetector(
                      onTap: () =>
                          context.push('/home/0/movie/${widget.video.id}'),
                      child: FadeIn(child: child));
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 200,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),

          //* Title
          SizedBox(
            width: 150,
            child: Text(
              widget.video.caption,
              maxLines: 2,
              style: textStyles.titleSmall,
            ),
          ),

          //* Rating
          /*SizedBox(
            width: 150,
            child: Row(
              children: [
                Icon(Icons.star_half_outlined, color: Colors.yellow.shade800),
                const SizedBox(width: 3),
                Text('${movie.voteAverage}',
                    style: textStyles.bodyMedium
                        ?.copyWith(color: Colors.yellow.shade800)),
                const Spacer(),
                Text(
                  HumanFormats.number(movie.popularity),
                  style: textStyles.bodySmall?.copyWith(
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          )*/
        ],
      ),
    );
  }
}
/*class VideoThumbnailCard extends StatefulWidget {
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
                    // Imagen del video (desde URL remota)
                    if (widget.video.imageUrl.isNotEmpty)
                      Image.network(
                        widget.video.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),

                    // Overlay oscuro
                    /*Container(
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
                    ),*/
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Título
            /*Text(
              '${widget.video.numberOfSeasons} Seasons',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight:
                    FontWeight.w300, // Bold porque en la imagen se ve grueso
                color: Color(0xFFB3B3B3),
              ),
            ),
            Text(
              widget.video.caption,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight:
                    FontWeight.w500, // Bold porque en la imagen se ve grueso
                color: Color(0xFFB3B3B3),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A), // Fondo #2A2A2A
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                widget.video.gender,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w500, // Bold porque en la imagen se ve grueso
                  color: Color(0xFFB3B3B3),
                ),
              ),
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
            ],*/
          ],
        ),
      ),
    );
  }
}*/
