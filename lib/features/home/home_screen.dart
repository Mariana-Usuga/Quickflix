import 'package:flutter/material.dart';
import 'package:quickflix/features/home/views/home_view.dart';
import 'package:quickflix/features/profile/profile_screen.dart';

import 'package:quickflix/features/widgets/home/bottom_navigation_bar.dart';
import 'package:quickflix/features/widgets/my_list/my_list_item.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home-screen';
  final int pageIndex;

  const HomeScreen({super.key, required this.pageIndex});

  final viewRoutes = const <Widget>[
    HomeView(),
    MyListItem(),
    ProfileScreen(),
    //PopularView(),
    //FavoritesView(),
  ];
/**  
 * PopularView(),
    SizedBox(),
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // para mantener el estado
        index: pageIndex,
        children: viewRoutes,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: pageIndex,
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quickflix/core/router/app_router.dart';
import 'package:quickflix/models/video_post.dart';
import 'package:quickflix/providers/discover_provider.dart';
import 'package:quickflix/features/widgets/home/top_bar.dart';
import 'package:quickflix/features/widgets/home/category_menu.dart';
import 'package:quickflix/features/widgets/home/video_info_card.dart';
import 'package:quickflix/features/widgets/home/bottom_navigation_bar.dart';
import 'package:quickflix/features/widgets/home/video_section.dart';
import 'package:quickflix/features/widgets/video/fullscreen_player.dart';
import 'package:quickflix/features/widgets/video/video_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

    // Video principal (hero)
    final heroVideo = videos[0];
    // Resto de videos para las secciones
    final popularVideos = videos.length > 1 ? videos.sublist(1) : <VideoPost>[];
    final continueWatchingVideos =
        videos.length > 4 ? videos.sublist(1, 4) : popularVideos;
    final topVideos = videos.length > 6 ? videos.sublist(0, 6) : videos;

    return Scaffold(
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
                  height: availableHeight * 0.75,
                  child: Stack(
                    children: [ 
                      // Video de fondo
                      SizedBox.expand(
                        child: FullScreenPlayer(
                          videoUrl: 'assets/videos/8.mp4',
                          caption: heroVideo.caption,
                        ),
                      ),

                      // Overlay oscuro
                      VideoBackground(
                        colors: const [Colors.transparent, Colors.black87],
                        stops: const [0.0, 1.0],
                      ),

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
                                    context.push(AppRouter.discover);
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
      // Barra de navegación inferior fija
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (navIndex) {
          switch (navIndex) {
            case 0:
              // Ya estamos en home
              break;
            case 2:
              context.go('/myList');
              break;
            case 3:
              context.go('/profile');
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}*/
