import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:quickflix/models/movie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MovieScreen extends StatefulWidget {
  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({super.key, required this.movieId});

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends State<MovieScreen> {
  Movie? movie;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  Future<void> _loadMovie() async {
    try {
      final response = await Supabase.instance.client
          .from('mux_videos')
          .select()
          .eq('id', int.parse(widget.movieId))
          .single();

      setState(() {
        movie = Movie.fromContentAnalysis(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    if (error != null || movie == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(error ?? 'Película no encontrada'),
        ),
      );
    }

    return Scaffold(
        body: CustomScrollView(
      slivers: [
        _CustomSliverAppBar(movie: movie!),
        SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => _MovieDetails(movie: movie!),
                childCount: 1))
      ],
    ));
  }
}

class _MovieDetails extends StatelessWidget {
  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: movie.posterPath.isNotEmpty
                    ? Image.network(
                        movie.posterPath,
                        width: size.width * 0.3,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: size.width * 0.3,
                            height: size.width * 0.45,
                            child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: size.width * 0.3,
                            height: size.width * 0.45,
                            color: Colors.grey[800],
                            child: const Icon(Icons.movie_outlined, size: 50),
                          );
                        },
                      )
                    : Container(
                        width: size.width * 0.3,
                        height: size.width * 0.45,
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie_outlined, size: 50),
                      ),
              ),
              const SizedBox(width: 10),
              // Descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: textStyles.titleLarge),
                    const SizedBox(height: 8),
                    if (movie.overview.isNotEmpty)
                      Text(
                        movie.overview,
                        style: textStyles.bodyMedium,
                      )
                    else
                      Text(
                        'Sin descripción disponible',
                        style: textStyles.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (movie.voteAverage > 0)
                      Row(
                        children: [
                          Icon(Icons.star_half_rounded,
                              color: Colors.yellow.shade800),
                          const SizedBox(width: 5),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: textStyles.bodyMedium?.copyWith(
                                color: Colors.yellow.shade900,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
        // Información adicional
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fecha de creación: ${_formatDate(movie.releaseDate)}',
                style: textStyles.bodySmall?.copyWith(color: Colors.grey),
              ),
              if (movie.originalLanguage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Idioma: ${movie.originalLanguage.toUpperCase()}',
                    style: textStyles.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CustomSliverAppBar extends StatelessWidget {
  final Movie movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          background: Stack(children: [
            SizedBox.expand(
              child: movie.posterPath.isNotEmpty
                  ? Image.network(
                      movie.posterPath,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress != null) {
                          return Container(
                            color: Colors.grey[900],
                            child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                          );
                        }
                        return FadeIn(child: child);
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[900],
                          child: const Center(
                              child: Icon(Icons.movie_outlined, size: 100)),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[900],
                      child: const Center(
                          child: Icon(Icons.movie_outlined, size: 100)),
                    ),
            ),
            const _CustomGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [
                  0.0,
                  0.2
                ],
                colors: [
                  Colors.black54,
                  Colors.transparent,
                ]),
            const _CustomGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.8, 1.0],
                colors: [Colors.transparent, Colors.black54]),
            const _CustomGradient(begin: Alignment.topLeft, stops: [
              0.0,
              0.3
            ], colors: [
              Colors.black87,
              Colors.transparent,
            ]),
          ])),
    );
  }
}

class _CustomGradient extends StatelessWidget {
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;

  const _CustomGradient(
      {this.begin = Alignment.centerLeft, //valores por defecto
      this.end = Alignment.centerRight,
      required this.stops,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: begin, end: end, stops: stops, colors: colors))),
    );
  }
}
