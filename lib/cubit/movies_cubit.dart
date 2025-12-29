import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickflix/models/episodes.dart';
import 'package:quickflix/models/video_post.dart';
import 'package:quickflix/services/local_video_services.dart';
import 'package:video_player/video_player.dart';

part 'movies_state.dart';

class MoviesCubit extends Cubit<MoviesState> {
  final LocalVideoServices localVideoServices;
  VideoPlayerController? _controller;
  final Map<String, VideoPlayerController> _controllerCache = {};
  String? _currentVideoUrl;

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

  Future<void> loadEpisodes(int titleId) async {
    try {
      emit(state.copyWith(isLoading: true));

      final newEpisodes =
          await localVideoServices.getEpisodesByTitleId(titleId);

      final orderedEpisodes = [
        ...state.episodes,
        ...newEpisodes,
      ]..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));

      emit(state.copyWith(
        episodes: orderedEpisodes,
        isLoading: false,
      ));
    } catch (e) {
      print('Error al cargar episodios: $e');
      emit(state.copyWith(
        isLoading: false,
        episodes: [],
      ));
    }
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
      // Pausar el controller anterior si existe y es diferente del nuevo
      if (_controller != null && _controller != _controllerCache[videoUrl]) {
        _controller!.pause();
      }

      // Si el video ya está en cache, usarlo directamente
      if (_controllerCache.containsKey(videoUrl)) {
        final cachedController = _controllerCache[videoUrl]!;
        if (cachedController.value.isInitialized) {
          _controller = cachedController;
          _currentVideoUrl = videoUrl;
          _controller!
            ..setVolume(0)
            ..setLooping(true)
            ..play();
          emit(state.copyWith(
            videoController: _controller,
            isVideoInitialized: true,
          ));
          return;
        }
      }

      // Si no está en cache, crear nuevo controller
      VideoPlayerController newController;
      if (videoUrl.isEmpty) {
        emit(state.copyWith(
          videoError: 'URL del video vacía',
        ));
        return;
      }

      if (videoUrl.startsWith('http')) {
        newController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      } else {
        newController = VideoPlayerController.asset(videoUrl);
      }

      await newController.initialize().timeout(
            const Duration(seconds: 30),
          );

      _controller = newController;
      _currentVideoUrl = videoUrl;
      _controllerCache[videoUrl] = newController;

      // Limpiar controllers antiguos del cache (mantener solo actual + siguiente + anterior)
      _cleanupOldControllers();

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

  /// Pre-carga un video sin activarlo
  Future<void> preloadVideo(String videoUrl) async {
    // Si ya está en cache y está inicializado, no hacer nada
    if (_controllerCache.containsKey(videoUrl)) {
      final cachedController = _controllerCache[videoUrl]!;
      if (cachedController.value.isInitialized) {
        return;
      }
    }

    // Si es el video actual, no pre-cargar
    if (videoUrl == _currentVideoUrl) {
      return;
    }

    try {
      if (videoUrl.isEmpty) return;

      VideoPlayerController newController;
      if (videoUrl.startsWith('http')) {
        newController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      } else {
        newController = VideoPlayerController.asset(videoUrl);
      }

      await newController.initialize().timeout(
            const Duration(seconds: 30),
          );

      // Guardar en cache sin reproducir
      _controllerCache[videoUrl] = newController;
      newController.setVolume(0);
      newController.setLooping(true);

      // Limpiar controllers antiguos del cache
      _cleanupOldControllers();
    } catch (e) {
      // Silenciar errores de pre-carga
      print('Error pre-cargando video: $e');
    }
  }

  /// Obtiene el controller para un video del cache
  VideoPlayerController? getControllerForVideo(String videoUrl) {
    return _controllerCache[videoUrl];
  }

  /// Limpia controllers antiguos del cache, manteniendo solo los necesarios
  void _cleanupOldControllers() {
    // Mantener máximo 3 videos en cache (actual + siguiente + anterior)
    // Por ahora, mantenemos todos en cache y solo limpiamos cuando hay muchos
    if (_controllerCache.length > 5) {
      // Encontrar y eliminar el controller más antiguo que no sea el actual
      String? oldestKey;
      for (final key in _controllerCache.keys) {
        if (key != _currentVideoUrl) {
          oldestKey = key;
          break;
        }
      }

      if (oldestKey != null) {
        final controllerToRemove = _controllerCache.remove(oldestKey);
        controllerToRemove?.dispose();
      }
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

  @override
  Future<void> close() async {
    // Limpiar todos los controllers del cache
    for (final controller in _controllerCache.values) {
      try {
        await controller.dispose();
      } catch (_) {}
    }
    _controllerCache.clear();
    _controller = null;
    return super.close();
  }
}
