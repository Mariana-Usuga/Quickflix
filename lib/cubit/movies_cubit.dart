import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickflix/models/episodes.dart';
import 'package:quickflix/models/video_post.dart';
import 'package:quickflix/services/local_video_services.dart';
import 'package:video_player/video_player.dart';

part 'movies_state.dart';

class MoviesCubit extends Cubit<MoviesState> {
  final LocalVideoServices localVideoServices;
  VideoPlayerController? _controller;

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

  void loadEpisodes(dynamic content) async {
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

  Future<void> initializeVideo(String videoUrl) async {
    emit(state.copyWith(
      isVideoInitialized: false,
      videoError: null,
      showVideoButtons: false,
    ));

    try {
      await _disposeVideo();

      if (videoUrl.isEmpty) {
        emit(state.copyWith(
          videoError: 'URL del video vacía',
        ));
        return;
      }

      if (videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      } else {
        _controller = VideoPlayerController.asset(videoUrl);
      }

      await _controller!.initialize().timeout(
            const Duration(seconds: 30),
          );

      _controller!
        ..setVolume(0)
        ..setLooping(true)
        ..play();

      emit(state.copyWith(
        videoController: _controller,
        isVideoInitialized: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        videoError: e.toString(),
        isVideoInitialized: false,
      ));
    }
  }

  void togglePlay() {
    if (_controller == null) return;

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }

    emit(state.copyWith(videoController: _controller));
  }

  void toggleVideoButtons() {
    emit(state.copyWith(showVideoButtons: !state.showVideoButtons));
  }

  Future<void> _disposeVideo() async {
    try {
      await _controller?.dispose();
    } catch (_) {}
    _controller = null;
  }

  @override
  Future<void> close() async {
    await _disposeVideo();
    return super.close();
  }
}
