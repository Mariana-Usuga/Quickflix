import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return //Container(
        //color: colors.primary,
        SafeArea(
      bottom: false,
      child: Padding(
        //padding: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 45),
        //child: Container(
        //color: colors.secondary,
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Icon(Icons.movie_outlined, color: colors.primary),
              const SizedBox(width: 10),
              Text('Cinemapedia', style: titleStyle),
              const Spacer(),
              IconButton(
                  onPressed: () {},
                  /*onPressed: () async {
                    //final movieRepository = ref.read(movieRepositoryProvider);
                    final searchedMovies = ref.read(searchedMoviesProvider);
                    final searchQuery = ref.read(searchQueryProvider);
                    //delagate:se encarga de trabajar la busqueda
                    showSearch<Movie?>(
                            query: searchQuery,
                            context: context,
                            delegate: SearchMovieDelegate(
                                initialMovies: searchedMovies,
                                searchMovies: ref
                                    .read(searchedMoviesProvider.notifier)
                                    .searchMoviesByQuery
                                /*(query) {
                              ref
                                  .read(searchQueryProvider.notifier)
                                  .update((state) => query);
                              return searchedMoviesProvider.searchMovies(query);
                            }*/
                                )) // dar la referencia
                        .then((movie) {
                      if (movie == null) return;
                      context.push('/home/0/movie/${movie.id}');
                    });
                    //print(movie?.title);
                  },*/
                  icon: const Icon(Icons.search))
            ],
          ),
        ),
      ),
    );
    //);
    //);
  }
}
