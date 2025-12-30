import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quickflix/cubit/movies_cubit.dart';
import 'package:quickflix/features/widgets/shared/move_item.dart';
import 'package:quickflix/models/movie.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Cargar los videos guardados cuando se inicializa el widget
    context
        .read<MoviesCubit>()
        .loadSavedVideosByProfileId('8057f308-db04-4775-8219-a882a6a4e5d6');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Heart icon
                  const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Text(
                    'My List',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  // Notification icon
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  // Wallet icon with badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '50',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: 'Saved'),
                Tab(text: 'Watching'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSavedList(), // Pestaña "Saved" - muestra videos guardados con MovieItem
                  _buildWatchingList(), // Pestaña "Watching" - otra lista
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la lista de videos guardados para la pestaña "Saved"
  /// Usa MovieItem para mostrar cada video guardado
  Widget _buildSavedList() {
    return BlocBuilder<MoviesCubit, MoviesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.savedVideos.isEmpty) {
          return const Center(
            child: Text(
              'No saved videos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          //padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: state.savedVideos.length,
          itemBuilder: (context, index) {
            final videoPost = state.savedVideos[index];
            final movie = Movie.fromVideoPost(videoPost);

            return MovieItem(
              movie: movie,
              onMovieSelected: (BuildContext context, Movie movie) {
                // Navegar a la pantalla de detalles del video
                context.push('/home/0/movie/${movie.id}');
              },
            );
          },
        );
      },
    );
  }

  /// Construye la lista de videos en reproducción para la pestaña "Watching"
  Widget _buildWatchingList() {
    // TODO: Implementar la lógica para videos en reproducción
    return const Center(
      child: Text(
        'Watching list coming soon',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
