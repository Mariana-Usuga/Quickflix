import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickflix/models/video_post.dart';
import 'package:quickflix/services/local_video_services.dart';

part 'movies_state.dart';

class MoviesCubit extends Cubit<MoviesState> {
  final LocalVideoServices localVideoServices;

  MoviesCubit({required this.localVideoServices}) : super(const MoviesState());

  void loadNextPage(dynamic content) async {
    if (state.isLoading || state.isLastPage) return;

    emit(state.copyWith(isLoading: true));

    final videos = await localVideoServices.getTrendingVideosByPage(1);

    if (videos.isEmpty) {
      emit(state.copyWith(isLoading: false, isLastPage: true));
      return;
    }

    emit(state.copyWith(
      isLastPage: false,
      isLoading: false,
      offset: state.offset + 10,
      videos: [...state.videos, ...videos],
    ));
  }

  void reset() {
    emit(const MoviesState());
  }

  /// Obtiene una película por su ID desde la lista de videos
  void getMovieById(int movieId) {
    try {
      final movie = state.videos.firstWhere(
        (video) => video.id == movieId,
        orElse: () => throw StateError('Movie not found'),
      );
      emit(state.copyWith(selectedMovie: movie));
    } catch (e) {
      emit(state.copyWith(selectedMovie: null));
    }
  }
}
