import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickflix/models/episodes.dart';
import 'package:quickflix/models/season.dart';
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

  /// Carga las temporadas según el title_id
  Future<void> loadSeasons(int titleId) async {
    try {
      emit(state.copyWith(isLoading: true));

      final seasons = await localVideoServices.getSeasonsByTitleId(titleId);

      emit(state.copyWith(
        seasons: seasons,
        isLoading: false,
      ));
    } catch (e) {
      print('Error al cargar temporadas: $e');
      emit(state.copyWith(
        isLoading: false,
        seasons: [],
      ));
    }
  }

  Future<void> loadEpisodes(int titleId) async {
    try {
      emit(state.copyWith(isLoading: true));

      final newEpisodes =
          await localVideoServices.getEpisodesByTitleId(titleId);

      // Ordenar episodios por número de episodio
      final orderedEpisodes = [...newEpisodes]
        ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));

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

  Future<void> _disposeVideo() async {
    try {
      await _controller?.dispose();
    } catch (_) {}
    _controller = null;
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

  /// Obtiene los videos guardados según el profile_id
  /// profile_id es un UUID (String)
  Future<void> loadSavedVideosByProfileId(String profileId) async {
    try {
      emit(state.copyWith(isLoading: true));

      final savedVideos =
          await localVideoServices.getSavedVideosByProfileId(profileId);

      emit(state.copyWith(
        savedVideos: savedVideos,
        isLoading: false,
        isLastPage: true, // Los videos guardados no tienen paginación
      ));
    } catch (e) {
      print('Error al cargar videos guardados: $e');
      emit(state.copyWith(
        isLoading: false,
        videos: [],
      ));
    }
  }

  /// Guarda un video y lo agrega a la lista savedVideos
  /// profile_id es un UUID (String)
  Future<void> saveVideo(String profileId, VideoPost video) async {
    try {
      // Guardar en la base de datos
      await localVideoServices.saveTitle(profileId, video.id);

      // Agregar a la lista local si no está ya guardado
      final currentSavedVideos = List<VideoPost>.from(state.savedVideos);
      if (!currentSavedVideos.any((v) => v.id == video.id)) {
        currentSavedVideos.insert(0, video); // Agregar al inicio
        emit(state.copyWith(savedVideos: currentSavedVideos));
      }
    } catch (e) {
      print('Error al guardar video: $e');
      rethrow;
    }
  }

  /// Elimina un video guardado de la lista savedVideos
  /// profile_id es un UUID (String)
  Future<void> removeSavedVideo(String profileId, int titleId) async {
    try {
      // Eliminar de la base de datos
      await localVideoServices.removeSavedTitle(profileId, titleId);

      // Eliminar de la lista local
      final currentSavedVideos = List<VideoPost>.from(state.savedVideos);
      currentSavedVideos.removeWhere((v) => v.id == titleId);
      emit(state.copyWith(savedVideos: currentSavedVideos));
    } catch (e) {
      print('Error al eliminar video guardado: $e');
      rethrow;
    }
  }

  /// Verifica si un video está guardado
  bool isVideoSaved(int titleId) {
    return state.savedVideos.any((video) => video.id == titleId);
  }

  /// Obtiene los videos en progreso según el profile_id
  /// profile_id es un UUID (String)
  Future<void> loadWatchingVideosByProfileId(String profileId) async {
    try {
      emit(state.copyWith(isLoading: true));

      final watchingVideos =
          await localVideoServices.getWatchingVideosByProfileId(profileId);

      emit(state.copyWith(
        watchingVideos: watchingVideos,
        isLoading: false,
      ));
    } catch (e) {
      print('Error al cargar videos en progreso: $e');
      emit(state.copyWith(
        isLoading: false,
        watchingVideos: [],
      ));
    }
  }

  @override
  Future<void> close() async {
    await _disposeVideo();
    return super.close();
  }
}
