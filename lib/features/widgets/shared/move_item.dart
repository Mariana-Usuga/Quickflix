import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickflix/cubit/movies_cubit.dart';
import 'package:quickflix/models/movie.dart';
import 'package:quickflix/models/video_post.dart';

class MovieItem extends StatefulWidget {
  final Movie movie;
  final Function(BuildContext, Movie) onMovieSelected; // cerrar el search
  final String profileId; // UUID del perfil del usuario

  const MovieItem({
    required this.movie,
    required this.onMovieSelected,
    required this.profileId,
  });

  @override
  State<MovieItem> createState() => _MovieItemState();
}

class _MovieItemState extends State<MovieItem> {
  String _formatViews(double views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}k';
    }
    return views.toStringAsFixed(0);
  }

  void _toggleBookmark() async {
    final cubit = context.read<MoviesCubit>();
    final isSaved = cubit.isVideoSaved(widget.movie.id);

    try {
      if (isSaved) {
        // Eliminar de guardados
        await cubit.removeSavedVideo(widget.profileId, widget.movie.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from saved'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        // Agregar a guardados
        final videoPost = VideoPost(
          id: widget.movie.id,
          caption: widget.movie.title,
          videoUrl: widget.movie.backdropPath,
          imageUrl: widget.movie.posterPath,
          likes: widget.movie.voteCount,
          views: widget.movie.popularity.toInt(),
          gender: '',
          numberOfSeasons: 0,
          synopsis: widget.movie.overview,
        );
        await cubit.saveVideo(widget.profileId, videoPost);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved to your list'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoviesCubit, MoviesState>(
      builder: (context, state) {
        final isSaved =
            context.read<MoviesCubit>().isVideoSaved(widget.movie.id);

        return GestureDetector(
          onTap: () {
            widget.onMovieSelected(context, widget.movie);
          },
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen vertical/portrait a la izquierda
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: // widget.movie.posterPath.isNotEmpty
                        Image.network(
                      widget.movie.posterPath,
                      width: 120,
                      height: 160,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        return FadeIn(child: child);
                      },
                    )),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    //margin: const EdgeInsets.only(top: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "4 Seasons" en gris claro arriba
                        Text(
                          '4 Seasons', // Valor por defecto, puedes ajustarlo según tus datos
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFB3B3B3),
                          ),
                        ),
                        SizedBox(height: 5),
                        // Título y bookmark icon
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movie.title,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                //maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF2A2A2A), // Fondo #2A2A2A
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'Romance',
                                  style: const TextStyle(
                                    color: Color(0xFFB3B3B3),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatViews(widget.movie.popularity)}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _toggleBookmark,
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? const Color(0xFFB11226) : Colors.white,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
