import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:quickflix/cubit/movies_cubit.dart';
import 'package:quickflix/features/widgets/home/movie_horizontal_list_top10.dart';
import 'package:quickflix/features/widgets/home/movie_horizontal_listview.dart';
import 'package:quickflix/features/widgets/home/movies_slideshow.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  initState() {
    super.initState();
    context.read<MoviesCubit>().loadNextPage(null);
  }

  @override
  Widget build(BuildContext context) {
    final videosBloc = context.read<MoviesCubit>();

    return BlocBuilder<MoviesCubit, MoviesState>(
        bloc: videosBloc,
        builder: (context, state) {
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: MoviesSlideshow(
                  movies: videosBloc.state.videos.take(5).toList()),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return Column(
                children: [
                  // const CustomAppbar(),

                  MovieHorizontalListView(
                    movies: videosBloc.state.videos,
                    title: 'Popular',
                    //subTitle: 'Lunes 20',
                    // loadNextPage: () =>
                    //   ref.read(nowPlayingMoviesProvider.notifier).loadNextPage()),
                  ),

                  MovieHorizontalListView(
                    movies: videosBloc.state.videos,
                    title: 'Continue Watching',
                    //subTitle: 'En este mes',
                    //loadNextPage: () =>
                    //  ref.read(popularMoviesProvider.notifier).loadNextPage(),
                  ),

                  MovieHorizontalListTop10(
                    movies: videosBloc.state.videos,
                    title: 'Weekly Top 10',
                    // subTitle: '',
                    //loadNextPage: () =>
                    //  ref.read(topRatedMoviesProvider.notifier).loadNextPage(),
                  ),

                  MovieHorizontalListView(
                    movies: videosBloc.state.videos,
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
        });
  }
}
