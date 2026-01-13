import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickflix/shared/cubits/titles/titles_cubit.dart';
import 'package:quickflix/features/widgets/home/movie_horizontal_listview.dart';
import 'package:quickflix/shared/entities/episode.dart';
import 'package:quickflix/shared/entities/season.dart';
import 'package:quickflix/shared/models/season_model.dart';
import 'package:quickflix/shared/entities/video_title.dart';

class MovieScreen extends StatefulWidget {
  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({super.key, required this.movieId});

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends State<MovieScreen> {
  //Movie? movie;;
  String? error;

  @override
  void initState() {
    super.initState();
    final moviesCubit = context.read<MoviesCubit>();
    final titleId = int.parse(widget.movieId);
    moviesCubit.getMovieById(titleId);
    // Cargar temporadas y episodios cuando se carga la película
    moviesCubit.loadSeasons(titleId);
    moviesCubit.loadEpisodes(titleId);
  }

  @override
  Widget build(BuildContext context) {
    final videosBloc = context.read<MoviesCubit>();

    return Scaffold(
        body: BlocBuilder<MoviesCubit, MoviesState>(
            bloc: videosBloc,
            builder: (context, state) {
              if (state.selectedMovie == null) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  _CustomSliverAppBar(movie: state.selectedMovie!),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _ContentDetails(movie: state.selectedMovie!),
                      childCount: 1,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(top: 50),
                      child: MovieHorizontalListView(
                        movies: videosBloc.state.videos,
                        title: 'You may also like',
                      ),
                    ),
                  ),
                ],
              );
            }));
  }
}

class _ContentDetails extends StatefulWidget {
  final VideoTitle movie;

  const _ContentDetails({required this.movie});

  @override
  State<_ContentDetails> createState() => _ContentDetailsState();
}

class _ContentDetailsState extends State<_ContentDetails> {
  int? selectedSeasonId;
  int selectedEpisode = 1;
  bool isSynopsisExpanded = false;

  @override
  void initState() {
    super.initState();
    // Inicializar selectedSeasonId cuando se carguen las temporadas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final moviesCubit = context.read<MoviesCubit>();
      if (moviesCubit.state.seasons.isNotEmpty) {
        setState(() {
          selectedSeasonId = moviesCubit.state.seasons.first.id;
        });
      }
    });
  }

  String _formatLikes(int likes) {
    if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(0)}k';
    }
    return likes.toString();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    return Container(
      //padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Column(
        children: [
          // Botones superiores: New, Romance, Play con views
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTag('New'),
                  const SizedBox(width: 6),
                  _buildTag(widget.movie.gender),
                  const SizedBox(width: 6),
                  _buildTag('50.7M'),
                ],
              ),

              const SizedBox(height: 20),

              // Botón grande "Jump Back In"
              SizedBox(
                width: 356,
                child: ElevatedButton(
                  onPressed: () => context.push('/home/0/discover'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB11226),
                    foregroundColor: Colors.white,
                    //padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Jump Back In',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight
                              .w600, // Bold porque en la imagen se ve grueso
                          color: const Color(0xFFF5F5F5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Métricas: Like, Bookmark, Share
              SizedBox(
                width: 182,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MetricButton(
                      icon: Icons.favorite_border_outlined,
                      label: _formatLikes(widget.movie.likes),
                    ),
                    _MetricButton(
                      icon: Icons.bookmark_border_outlined,
                      label: '2,000',
                    ),
                    _MetricButton(
                      icon: Icons.share,
                      label: 'Share',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Título
              Text(
                widget.movie.caption,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w500, // Bold porque en la imagen se ve grueso
                  color: const Color(0xFFF5F5F5),
                ),
              ),
              const SizedBox(height: 8),

              // Sinopsis con botón "More"
              _SynopsisText(
                text: widget.movie.synopsis.isNotEmpty
                    ? widget.movie.synopsis
                    : 'Sin descripción disponible',
                isExpanded: isSynopsisExpanded,
                onTap: () {
                  setState(() {
                    isSynopsisExpanded = !isSynopsisExpanded;
                  });
                },
              ),
              const SizedBox(height: 20),
            ]),
          ),

          // Navegación de Temporadas y Episodios
          BlocBuilder<MoviesCubit, MoviesState>(
            builder: (context, state) {
              final seasons = state.seasons;
              final allEpisodes = state.episodes;

              // Filtrar episodios por temporada seleccionada
              Season? selectedSeason;
              if (selectedSeasonId != null && seasons.isNotEmpty) {
                try {
                  selectedSeason = seasons.firstWhere(
                    (s) => s.id == selectedSeasonId,
                  );
                } catch (e) {
                  // Si no se encuentra la temporada seleccionada, usar la primera
                  selectedSeason = seasons.first;
                  selectedSeasonId = selectedSeason.id;
                }
              } else if (seasons.isNotEmpty) {
                selectedSeason = seasons.first;
                selectedSeasonId = selectedSeason.id;
              }

              final episodesForSeason = selectedSeason != null
                  ? allEpisodes
                      .where((ep) => ep.seasonId == selectedSeason!.id)
                      .toList()
                  : <Episode>[];

              // Inicializar selectedSeasonId si no está establecido
              if (selectedSeasonId == null &&
                  seasons.isNotEmpty &&
                  selectedSeason != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      selectedSeasonId = selectedSeason!.id;
                    });
                  }
                });
              }

              return Container(
                margin: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Navegación de Temporadas
                    if (seasons.isNotEmpty) ...[
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: seasons.length,
                          itemBuilder: (context, index) {
                            final season = seasons[index];
                            final isSelected = season.id == selectedSeasonId;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _SeasonButton(
                                label: season.name,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    selectedSeasonId = season.id;
                                    selectedEpisode = 1;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Episodios
                    Text(
                      'Episodes',
                      style: textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 60,
                      child: episodesForSeason.isEmpty
                          ? const Center(
                              child: Text(
                                'No episodes available',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: episodesForSeason.length,
                              itemBuilder: (context, index) {
                                final episode = episodesForSeason[index];
                                final isSelected =
                                    episode.episodeNumber == selectedEpisode;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _EpisodeButton(
                                    number: episode.episodeNumber,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        selectedEpisode = episode.episodeNumber;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          )
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

class _MetricButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight:
                FontWeight.w500, // Bold porque en la imagen se ve grueso
            color: const Color(0xFFF5F5F5),
          ), /*TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),*/
        ),
      ],
    );
  }
}

class _SynopsisText extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SynopsisText({
    required this.text,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const maxLines = 3;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight:
                  FontWeight.w400, // Bold porque en la imagen se ve grueso
              color: const Color(0xFFB3B3B3),
            ),
            /* textStyles.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),*/
            maxLines: isExpanded ? null : maxLines,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
          if (text.length > 150)
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isExpanded ? 'Less' : 'More',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w700, // Bold porque en la imagen se ve grueso
                  color: const Color(0xFFF5F5F5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SeasonButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeasonButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
/**
 * ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB11226),
                    foregroundColor: Colors.white,
                    //padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Jump Back In',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight
                              .w600, // Bold porque en la imagen se ve grueso
                          color: const Color(0xFFF5F5F5),
                        ),
                      ),
                    ],
                  ),
                ),
 */
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //height: 32,
            //width: 112,
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF2A2A2A) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight:
                    FontWeight.w600, // Bold porque en la imagen se ve grueso
                color: const Color(0xFFF5F5F5),
              ),
            ),
          ),
        ],
      ), /*Container(
        //padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 32,
        width: 112,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2A2A2A) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight:
                FontWeight.w600, // Bold porque en la imagen se ve grueso
            color: const Color(0xFFF5F5F5),
            //height: 22,
          ), /*TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),*/
        ),
      ),*/
    );
  }
}

class _EpisodeButton extends StatelessWidget {
  final int number;
  final bool isSelected;
  final VoidCallback onTap;

  const _EpisodeButton({
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 63,
        height: 57,
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey[900],
          //shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight:
                  FontWeight.w500, // Bold porque en la imagen se ve grueso
              color: const Color(0xFFF5F5F5),
            ), /*TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),*/
          ),
        ),
      ),
    );
  }
}

class _CustomSliverAppBar extends StatelessWidget {
  final VideoTitle movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          background: Stack(children: [
            SizedBox.expand(
              child: movie.imageUrl.isNotEmpty
                  ? Image.network(
                      movie.imageUrl,
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
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [0.0, 0.4],
              colors: [Color(0xFF121212), Colors.transparent],
            ),
            const _CustomGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.3],
              colors: [Color.fromARGB(255, 0, 0, 0), Colors.transparent],
            ),
            /*const _CustomGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.0, 0.2],
              colors: [
                Colors.black54,
                Colors.transparent,
              ],
            ),
            const _CustomGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.8, 1.0],
              colors: [Colors.transparent, Colors.black54],
            ),
            const _CustomGradient(
              begin: Alignment.topLeft,
              stops: [0.0, 0.3],
              colors: [
                Colors.black87,
                Colors.transparent,
              ],
            ),*/
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
