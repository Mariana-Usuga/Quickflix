import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickflix/shared/entities/episode.dart';
import 'package:quickflix/shared/entities/season.dart';
import 'package:quickflix/shared/entities/video_title.dart';
import 'package:quickflix/services/local_video_services.dart';
import 'package:video_player/video_player.dart';

part 'titles_state.dart';

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
    // Si la URL no cambió, no hacer nada
    if (state.currentVideoUrl == videoUrl && state.isVideoInitialized) {
      return;
    }

    // Limpiar controller anterior si existe
    if (state.videoController != null) {
      await state.videoController!.dispose();
    }

    // Validar que la URL no esté vacía
    if (videoUrl.isEmpty) {
      emit(state.copyWith(
        videoError: 'URL del video vacía',
        isVideoInitialized: false,
        videoController: null,
        currentVideoUrl: videoUrl,
      ));
      return;
    }

    // Resetear estado
    emit(state.copyWith(
      isVideoInitialized: false,
      videoError: null,
      videoController: null,
      currentVideoUrl: videoUrl,
      showVideoButtons: false,
    ));

    VideoPlayerController? newController;
    try {
      // Detectar si es un asset local o una URL de red
      if (videoUrl.startsWith('http://') || videoUrl.startsWith('https://')) {
        // Es una URL de red (Mux, etc.)
        newController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );
      } else {
        // Es un asset local
        newController = VideoPlayerController.asset(videoUrl);
      }

      // Inicializar con timeout
      await newController.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              'Timeout al inicializar el video después de 30 segundos');
        },
      );

      // Configurar el video
      newController
        ..setVolume(0)
        ..setLooping(true) //se repite infinitamente
        ..play();

      // Actualizar el controller interno
      _controller = newController;

      // Emitir estado de éxito
      emit(state.copyWith(
        videoController: newController,
        isVideoInitialized: true,
        videoError: null,
        currentVideoUrl: videoUrl,
      ));
    } catch (e) {
      print('Error al inicializar el video: $e');
      print('URL del video: $videoUrl');

      // Limpiar el controller si hay error
      try {
        await newController?.dispose();
      } catch (disposeError) {
        print('Error al limpiar controller: $disposeError');
      }

      _controller = null;

      // Emitir estado de error
      emit(state.copyWith(
        isVideoInitialized: false,
        videoError: 'Error: $e',
        videoController: null,
        currentVideoUrl: videoUrl,
      ));
    }
  }

  /**
   * Future<void> initializeVideo(String videoUrl) async {
    // Si la URL no cambió, no hacer nada
    if (state.currentVideoUrl == videoUrl && state.isInitialized) {
      return;
    }

    // Limpiar controller anterior si existe
    if (state.controller != null) {
      await state.controller!.dispose();
    }

    // Validar que la URL no esté vacía
    if (videoUrl.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'URL del video vacía',
        isInitialized: false,
        controller: null,
      ));
      return;
    }

    // Resetear estado
    emit(state.copyWith(
      isInitialized: false,
      errorMessage: null,
      controller: null,
      currentVideoUrl: videoUrl,
    ));

    VideoPlayerController? newController;
    try {
      // Detectar si es un asset local o una URL de red
      if (videoUrl.startsWith('http://') || videoUrl.startsWith('https://')) {
        // Es una URL de red (Mux, etc.)
        newController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );
      } else {
        // Es un asset local
        newController = VideoPlayerController.asset(videoUrl);
      }

      // Inicializar con timeout
      await newController.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              'Timeout al inicializar el video después de 30 segundos');
        },
      );

      // Configurar el video
      newController
        ..setVolume(0)
        ..setLooping(true) //se repite infinitamente
        ..play();

      // Emitir estado de éxito
      emit(state.copyWith(
        controller: newController,
        isInitialized: true,
        errorMessage: null,
        currentVideoUrl: videoUrl,
      ));
    } catch (e) {
      print('Error al inicializar el video: $e');
      print('URL del video: $videoUrl');

      // Limpiar el controller si hay error
      try {
        await newController?.dispose();
      } catch (disposeError) {
        print('Error al limpiar controller: $disposeError');
      }

      // Emitir estado de error
      emit(state.copyWith(
        isInitialized: false,
        errorMessage: 'Error: $e',
        controller: null,
        currentVideoUrl: videoUrl,
      ));
    }
  }
   */

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

  void togglePlayPause() {
    final controller = state.videoController;
    if (controller != null && controller.value.isInitialized) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    }
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
  Future<void> saveVideo(String profileId, VideoTitle video) async {
    try {
      // Guardar en la base de datos
      await localVideoServices.saveTitle(profileId, video.id);

      // Agregar a la lista local si no está ya guardado
      final currentSavedVideos = List<VideoTitle>.from(state.savedVideos);
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
      final currentSavedVideos = List<VideoTitle>.from(state.savedVideos);
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

  /// Guarda el progreso actual del video en Supabase
  Future<void> saveCurrentProgress({
    required String profileId,
    required int titleId,
    int? episodeId,
  }) async {
    // 1. Validar que el controlador esté listo y reproduciendo
    final controller = state.videoController;
    if (controller == null || !state.isVideoInitialized) return;

    // 2. Capturar la posición actual en segundos
    final currentSeconds = controller.value.position.inSeconds;

    // 3. No guardar si es el segundo 0 (evitar llamadas innecesarias)
    if (currentSeconds <= 0) return;

    try {
      // 4. Enviar a la base de datos
      await localVideoServices.updateVideoProgress(
        profileId: profileId,
        titleId: titleId,
        episodeId: episodeId!,
        seconds: currentSeconds,
      );

      // 5. Refrescar la lista de "Watching" para que la UI esté al día
      // Esto actualiza state.watchingVideos en la Opción A que elegimos
      await loadWatchingVideosByProfileId(profileId);

      print('Progreso guardado exitosamente: $currentSeconds seg.');
    } catch (e) {
      print('Error al guardar progreso: $e');
    }
  }

  @override
  Future<void> close() async {
    await _disposeVideo();
    return super.close();
  }
}
