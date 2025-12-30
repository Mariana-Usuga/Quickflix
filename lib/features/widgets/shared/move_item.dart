import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickflix/models/movie.dart';

class MovieItem extends StatelessWidget {
  final Movie movie;
  final Function(BuildContext, Movie) onMovieSelected; // cerrar el search

  const MovieItem({required this.movie, required this.onMovieSelected});

  String _formatViews(double views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}k';
    }
    return views.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onMovieSelected(context, movie);
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
                child: // movie.posterPath.isNotEmpty
                    Image.network(
                  movie.posterPath,
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
                            movie.title,
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
                              color: const Color(0xFF2A2A2A), // Fondo #2A2A2A
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
                          '${_formatViews(movie.popularity)}',
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
              onPressed: () {},
              icon: const Icon(
                Icons.bookmark_border,
                color: Colors.white,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
