import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickflix/shared/cubits/titles/titles_cubit.dart';
import 'package:quickflix/features/widgets/home/movie_horizontal_list_top10.dart';
import 'package:quickflix/features/widgets/home/movie_horizontal_listview.dart';
import 'package:quickflix/features/widgets/home/movies_slideshow.dart';

class HomeView extends StatefulWidget {
  // Cambiado a Stateless porque el Cubit lleva el estado
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  initState() {
    super.initState();
    Future.microtask(() {
      context.read<MoviesCubit>().changeCategory('All');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos watch para que el widget se reconstruya cuando el estado cambie
    final state = context.watch<MoviesCubit>().state;
    final videos = state.videos;

    return CustomScrollView(
      slivers: [
        // 1. EL SLIDESHOW (Siempre presente, pero con datos filtrados)
        SliverToBoxAdapter(
          child: MoviesSlideshow(
            movies: videos.take(5).toList(),
          ),
        ),

        // 2. CONTENIDO DINÁMICO
        if (state.isLoading && videos.isEmpty)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: Colors.red)),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Column(
                  children: [
                    // Si el filtro es "All", mostramos diseño de "Home"
                    if (state.selectedCategory == 'All') ...[
                      MovieHorizontalListView(
                        movies: videos,
                        title: 'Popular',
                      ),
                      MovieHorizontalListView(
                        movies: videos.reversed.toList(),
                        title: 'Continue Watching',
                      ),
                      MovieHorizontalListTop10(
                        movies: videos.reversed.toList(),
                        title: 'Weekly Top 10',
                      ),
                      MovieHorizontalListView(
                        movies: videos.reversed.toList(),
                        title: 'Because you watched Accidentally in His Arms ',
                      ),
                      const SizedBox(height: 10),
                    ]
                    // Si es un filtro específico (ej. Acción), mostramos solo lo relevante
                    else ...[
                      MovieHorizontalListView(
                        movies: videos,
                        title: 'Trending in ${state.selectedCategory}',
                      ),

                      // 2. Los mejor calificados (Ordenamos por rating de mayor a menor)
                      MovieHorizontalListView(
                        movies: [...videos]
                          ..sort((a, b) => b.rating.compareTo(a.rating)),
                        title: 'Top Rated ${state.selectedCategory}',
                      ),

                      // 3. Los más nuevos (Ordenamos por fecha)
                      MovieHorizontalListView(
                        movies: [...videos]..sort(
                            (a, b) => b.releaseDate.compareTo(a.releaseDate)),
                        title: 'Fresh ${state.selectedCategory} Hits',
                      ),

                      // 4. "Must Watch" (Simplemente invertimos el orden para que se vea diferente)
                      MovieHorizontalListView(
                        movies: videos.reversed.toList(),
                        title: 'Must Watch',
                      ),
                      // Aquí podrías agregar un GridView si prefieres ver más
                    ],

                    const SizedBox(height: 30),
                  ],
                );
              },
              childCount: 1,
            ),
          ),
      ],
    );
  }
}

/*class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  initState() {
    super.initState();
    context.read<MoviesCubit>().loadNextPage();
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
                  ),

                  MovieHorizontalListView(
                    movies: videosBloc.state.videos,
                    title: 'Continue Watching',
                  ),

                  MovieHorizontalListTop10(
                    movies: videosBloc.state.videos,
                    title: 'Weekly Top 10',
                  ),

                  MovieHorizontalListView(
                    movies: videosBloc.state.videos,
                    title: 'Because you watched Accidentally in His Arms ',
                  ),

                  const SizedBox(height: 10),
                ],
              );
            }, childCount: 1)),
          ]);
        });
  }
}*/
