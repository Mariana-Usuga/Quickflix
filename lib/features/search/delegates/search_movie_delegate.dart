import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickflix/features/widgets/shared/move_item.dart';

import 'package:quickflix/models/movie.dart';

typedef SearchMoviesCallback = Future<List<Movie>> Function(String query);

class SearchMovieDelegate extends SearchDelegate<Movie?> {
  final SearchMoviesCallback searchMovies;

  List<Movie> initialMovies;

  StreamController<List<Movie>> debouncedMovies = StreamController.broadcast();

  StreamController<bool> isLoadingStream = StreamController.broadcast();

  Timer? _debounceTimer;

  SearchMovieDelegate({required this.searchMovies, required this.initialMovies})
      : super(
          searchFieldLabel: 'Search',
        );

  void clearStreams() {
    _debounceTimer?.cancel();
    debouncedMovies.close();
    isLoadingStream.close();
  }

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);
    print('Query string cambio');

    //si esta activo el temporizador se cancela para que vuelva a empezar
    // el temporizador
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    //cuando deje de escribir por 500 milliseconds hace la peticion
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final movies = await searchMovies(query);
      debouncedMovies.add(movies);
      initialMovies = movies;
      isLoadingStream.add(false);
    });
  }

  Widget buildResultsAndSuggestions() {
    return StreamBuilder(
      initialData: initialMovies,
      stream: debouncedMovies.stream,
      builder: (context, snapshot) {
        final movies = snapshot.data ?? [];

        if (movies.isEmpty && query.isNotEmpty) {
          return const Center(
            child: Text(
              'No Results Found',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => MovieItem(
            movie: movies[index],
            profileId:
                '8057f308-db04-4775-8219-a882a6a4e5d6', // TODO: Obtener del usuario autenticado
            onMovieSelected: (BuildContext context, Movie movie) {
              clearStreams();
              // Navegar a MovieScreen y cerrar el search
              context.push('/home/0/movie/${movie.id}');
              close(context, movie);
            },
          ),
        );
      },
    );
  }

  @override
  String get searchFieldLabel => 'Search';

  @override
  List<Widget>? buildActions(BuildContext context) {
    print('el que elimina lo que la persona escribio o carga');
    return [
      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
          if (snapshot.data ?? false) {
            print('hii');
            return SpinPerfect(
              duration: const Duration(seconds: 20),
              spins: 10,
              infinite: true,
              child: IconButton(
                  onPressed: () => query = '', icon: const Icon(Icons.refresh)),
            );
          }
          return FadeIn(
            animate: query.isNotEmpty,
            child: IconButton(
                onPressed: () => query = '', icon: const Icon(Icons.clear)),
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    //null: supongo que la persona no hizo nada
    print('buildLeading, para salir de la busqueda');
    return IconButton(
        onPressed: () {
          clearStreams();
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back_ios_new_outlined));
  }

  @override
  Widget buildResults(BuildContext context) {
    print('buildResults, se ejecuta al presionar enter');
    return buildResultsAndSuggestions();
  }

  @override // peticion cada vez que presiono una tecla
  Widget buildSuggestions(BuildContext context) {
    print('buildSuggestions, se dispara cada vez que la persona escribe algo');
    if (query.isNotEmpty) {
      _onQueryChanged(query);
    }
    return buildResultsAndSuggestions();
  }
}
