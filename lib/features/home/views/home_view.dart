import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quickflix/features/widgets/home/movie_horizontal_listview.dart';
import 'package:quickflix/features/widgets/home/movies_slideshow.dart';
import 'package:quickflix/models/video_post.dart';
import 'package:quickflix/providers/discover_provider.dart';
import 'package:quickflix/features/widgets/home/top_bar.dart';
import 'package:quickflix/features/widgets/home/category_menu.dart';
import 'package:quickflix/features/widgets/home/video_info_card.dart';
import 'package:quickflix/features/widgets/home/video_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _selectedCategory = 'Popular';

  @override
  Widget build(BuildContext context) {
    final discoverProvider = context.watch<DiscoverProvider>();

    if (discoverProvider.initialLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final videos = discoverProvider.videos;
    if (videos.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No hay videos disponibles'),
        ),
      );
    }

    // Video principal (hero) - Validar que existe antes de acceder
    final heroVideo = videos[0];
    // Resto de videos para las secciones
    final popularVideos = videos.length > 1 ? videos.sublist(1) : <VideoPost>[];
    final continueWatchingVideos =
        videos.length > 4 ? videos.sublist(1, 4) : popularVideos;
    final topVideos = videos.length > 6 ? videos.sublist(0, 6) : videos;

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: MoviesSlideshow(movies: videos),
      ),
      /*SliverAppBar(
        floating: true,
        //flexibleSpace: FlexibleSpaceBar(
        title: CustomAppbar(),
        //),
      ),*/
      /*SliverToBoxAdapter(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            final safeAreaTop = MediaQuery.of(context).padding.top;
            final safeAreaBottom = MediaQuery.of(context).padding.bottom;
            final availableHeight = screenHeight - safeAreaTop - safeAreaBottom;

            return SizedBox(
              height: availableHeight * 0.85,
              child: Stack(
                children: [
                  // Imagen de fondo
                  SizedBox.expand(
                    child: Image.asset(
                      'assets/background.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Si falla la carga de la imagen, mostrar un color de fondo
                        return Container(
                          color: const Color(0xFF121212),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  _CustomGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [
                        0.0,
                        0.3
                      ],
                      colors: [
                        Color(0xFF121212),
                        Colors.transparent,
                      ]),

                  // Contenido superpuesto
                  SafeArea(
                    child: Column(
                      children: [
                        // Barra superior
                        const TopBar(),

                        const SizedBox(height: 5),

                        // Menú de categorías
                        CategoryMenu(
                          selectedCategory: _selectedCategory,
                          onCategorySelected: (category) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),

                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: VideoInfoCard(
                              video: heroVideo,
                              currentIndex: 0,
                              totalVideos: 1,
                              onPlayPressed: () {
                                // Navegar a la pantalla de scroll vertical
                                context.push('/discover');
                              },
                            ),
                          ),
                        ),

                        //const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),*/
      SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
        return Column(
          children: [
            // const CustomAppbar(),

            MovieHorizontalListView(
              movies: continueWatchingVideos,
              title: 'Popular',
              //subTitle: 'Lunes 20',
              // loadNextPage: () =>
              //   ref.read(nowPlayingMoviesProvider.notifier).loadNextPage()),
            ),

            MovieHorizontalListView(
              movies: continueWatchingVideos,
              title: 'Continue Watching',
              //subTitle: 'En este mes',
              //loadNextPage: () =>
              //  ref.read(popularMoviesProvider.notifier).loadNextPage(),
            ),

            MovieHorizontalListView(
              movies: continueWatchingVideos,
              title: 'top',
              // subTitle: '',
              //loadNextPage: () =>
              //  ref.read(topRatedMoviesProvider.notifier).loadNextPage(),
            ),

            MovieHorizontalListView(
              movies: continueWatchingVideos,
              title: 'Proximamente',
              subTitle: 'Desde siempre',
              //loadNextPage: () =>
              //  ref.read(upcomingMoviesProvider.notifier).loadNextPage(),
            ),

            const SizedBox(height: 10),
          ],
        );
      }, childCount: 1)),
    ]);
  }
}
/* Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Section con video principal
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = MediaQuery.of(context).size.height;
                final safeAreaTop = MediaQuery.of(context).padding.top;
                final safeAreaBottom = MediaQuery.of(context).padding.bottom;
                final availableHeight =
                    screenHeight - safeAreaTop - safeAreaBottom;

                return SizedBox(
                  height: availableHeight * 0.85,
                  child: Stack(
                    children: [
                      // Imagen de fondo
                      SizedBox.expand(
                        child: Image.asset(
                          'assets/background.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Si falla la carga de la imagen, mostrar un color de fondo
                            return Container(
                              color: const Color(0xFF121212),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Overlay oscuro
                      /*VideoBackground(
                        colors: const [Colors.transparent, Colors.black87],
                        stops: const [0.0, 1.0],
                      ),*/
                      _CustomGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: [
                            0.0,
                            0.3
                          ],
                          colors: [
                            Color(0xFF121212),
                            Colors.transparent,
                          ]),

                      // Contenido superpuesto
                      SafeArea(
                        child: Column(
                          children: [
                            // Barra superior
                            const TopBar(),

                            const SizedBox(height: 5),

                            // Menú de categorías
                            CategoryMenu(
                              selectedCategory: _selectedCategory,
                              onCategorySelected: (category) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            ),

                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: VideoInfoCard(
                                  video: heroVideo,
                                  currentIndex: 0,
                                  totalVideos: 1,
                                  onPlayPressed: () {
                                    // Navegar a la pantalla de scroll vertical
                                    context.push('/discover');
                                  },
                                ),
                              ),
                            ),

                            //const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Secciones de videos
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección Popular
                if (popularVideos.isNotEmpty)
                  VideoSection(
                    title: 'Popular',
                    videos: popularVideos,
                  ),

                // Sección Continue Watching
                if (continueWatchingVideos.isNotEmpty)
                  VideoSection(
                    title: 'Continue Watching',
                    videos: continueWatchingVideos,
                    showEpisodeInfo: true,
                  ),

                // Sección Weekly Top 10
                if (topVideos.isNotEmpty)
                  VideoSection(
                    title: 'Weekly Top 10',
                    videos: topVideos,
                  ),

                // Sección Because you watched
                if (popularVideos.isNotEmpty)
                  VideoSection(
                    title: 'Because you watched Accidentally in His Arms',
                    videos: popularVideos,
                    showEpisodeInfo: true,
                  ),

                const SizedBox(
                    height: 80), // Espacio para la barra de navegación
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/

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
