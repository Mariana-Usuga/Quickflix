import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickflix/models/video_post.dart';

class MovieHorizontalListView extends StatefulWidget {
  final List<VideoPost> movies;
  final String? title;
  final String? subTitle;
  final VoidCallback? loadNextPage;

  const MovieHorizontalListView(
      {super.key,
      required this.movies,
      this.title,
      this.subTitle,
      this.loadNextPage});

  @override
  State<MovieHorizontalListView> createState() =>
      _MovieHorizontalListViewState();
}

class _MovieHorizontalListViewState extends State<MovieHorizontalListView> {
  final scrollController = ScrollController();

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

  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Column(children: [
        if (widget.title != null || widget.subTitle != null)
          _Title(title: widget.title, subTitle: widget.subTitle),
        Expanded(
            child: ListView.builder(
          controller: scrollController,
          itemCount: widget.movies.length,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return FadeInRight(child: _Slide(movie: widget.movies[index]));
          },
        ))
      ]),
    );
  }
}

class _Slide extends StatelessWidget {
  final VideoPost movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* Imagen
          SizedBox(
            width: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                movie.imageUrl,
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
                      onTap: () => context.push('/home/0/movie/${movie.id}'),
                      child: FadeIn(child: child));
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Título
          Text(
            '${movie.numberOfSeasons} Seasons',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight:
                  FontWeight.w300, // Bold porque en la imagen se ve grueso
              color: Color(0xFFB3B3B3),
            ),
          ),
          Text(
            movie.caption,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight:
                  FontWeight.w500, // Bold porque en la imagen se ve grueso
              color: Color(0xFFB3B3B3),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A), // Fondo #2A2A2A
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              movie.gender,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight:
                    FontWeight.w500, // Bold porque en la imagen se ve grueso
                color: Color(0xFFB3B3B3),
              ),
            ),
          ),
          //* Title
          /*SizedBox(
            width: 150,
            child: Text(
              movie.caption,
              maxLines: 2,
              style: textStyles.titleSmall,
            ),
          ),*/

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

class _Title extends StatelessWidget {
  final String? title;
  final String? subTitle;

  const _Title({this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w600, // Bold porque en la imagen se ve grueso
      color: Color(0xFFFFFFFF),
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
