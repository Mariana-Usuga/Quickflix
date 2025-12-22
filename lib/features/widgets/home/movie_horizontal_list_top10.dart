import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickflix/models/video_post.dart';

class MovieHorizontalListTop10 extends StatefulWidget {
  final List<VideoPost> movies;
  final String? title;
  final String? subTitle;
  final VoidCallback? loadNextPage;

  const MovieHorizontalListTop10({
    super.key,
    required this.movies,
    this.title,
    this.subTitle,
    this.loadNextPage,
  });

  @override
  State<MovieHorizontalListTop10> createState() =>
      _MovieHorizontalListTop10State();
}

class _MovieHorizontalListTop10State extends State<MovieHorizontalListTop10> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (widget.loadNextPage == null) return;

      if ((scrollController.position.pixels + 200) >=
          scrollController.position.maxScrollExtent) {
        print('load next movies');
        widget.loadNextPage!();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500, // Altura mayor para las tarjetas verticales
      child: Column(children: [
        if (widget.title != null || widget.subTitle != null)
          _Title(title: widget.title, subTitle: widget.subTitle),
        Expanded(
            child: ListView.builder(
          controller: scrollController,
          itemCount: widget.movies.length,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20), // Padding para que el número sobresalga
          clipBehavior: Clip.none, // Permite que los items sobresalgan
          itemBuilder: (context, index) {
            return FadeInRight(
                child:
                    _Top10Slide(movie: widget.movies[index], rank: index + 1));
          },
        ))
      ]),
    );
  }
}

class _Top10Slide extends StatelessWidget {
  final VideoPost movie;
  final int rank;

  const _Top10Slide({required this.movie, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 220, // Ancho mayor para tarjetas verticales
      child: Stack(
        clipBehavior:
            Clip.none, // Permite que los hijos sobresalgan del contenedor
        children: [
          // Imagen de fondo (primero, queda atrás)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              movie.imageUrl,
              fit: BoxFit.cover,
              width: 220,
              height: 450,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress != null) {
                  return Container(
                    width: 220,
                    height: 450,
                    color: const Color(0xFF121212),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () => context.push('/home/0/movie/${movie.id}'),
                  child: FadeIn(child: child),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 220,
                  height: 450,
                  color: const Color(0xFF121212),
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                );
              },
            ),
          ),

          // Imagen del número desde assets que sobresale de la tarjeta (último, queda encima)
          Positioned(
            top: -20, // Valor negativo para que sobresalga hacia arriba
            left: -15, // Valor negativo para que sobresalga hacia la izquierda
            child: Image.asset(
              'assets/2.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Si la imagen no se encuentra, mostrar un placeholder
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.withOpacity(0.3),
                  child: const Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String? title;
  final String? subTitle;

  const _Title({this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFFFFFFF),
    );

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          if (title != null) Text(title!, style: titleStyle),
          const Spacer(),
          if (subTitle != null)
            FilledButton.tonal(
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                onPressed: () {},
                child: Text(subTitle!))
        ],
      ),
    );
  }
}
