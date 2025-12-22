import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickflix/features/widgets/home/movie_horizontal_list_top10.dart';
import 'package:quickflix/features/widgets/home/movie_horizontal_listview.dart';
import 'package:quickflix/features/widgets/home/movies_slideshow.dart';
import 'package:quickflix/models/video_post.dart';
import 'package:quickflix/providers/discover_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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

    // Resto de videos para las secciones
    final popularVideos = videos.length > 1 ? videos.sublist(1) : <VideoPost>[];
    final continueWatchingVideos =
        videos.length > 4 ? videos.sublist(1, 4) : popularVideos;

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: MoviesSlideshow(movies: videos.take(5).toList()),
      ),
      SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
        return Column(
          children: [
            // const CustomAppbar(),

            MovieHorizontalListView(
              movies: popularVideos,
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

            MovieHorizontalListTop10(
              movies: continueWatchingVideos,
              title: 'Weekly Top 10',
              // subTitle: '',
              //loadNextPage: () =>
              //  ref.read(topRatedMoviesProvider.notifier).loadNextPage(),
            ),

            MovieHorizontalListView(
              movies: continueWatchingVideos,
              title: 'Because you watched Accidentally in His Arms ',
              // subTitle: '',
              //loadNextPage: () =>
              //  ref.read(topRatedMoviesProvider.notifier).loadNextPage(),
            ),

            const SizedBox(height: 10),
          ],
        );
      }, childCount: 1)),
    ]);
  }
}
