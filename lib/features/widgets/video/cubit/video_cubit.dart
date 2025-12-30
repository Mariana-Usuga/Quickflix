import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

part 'video_state.dart';

class VideoCubit extends Cubit<VideoState> {
  VideoCubit() : super(const VideoState());

  Future<void> initializeVideo(String videoUrl) async {
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

  void togglePlayPause() {
    final controller = state.controller;
    if (controller != null && controller.value.isInitialized) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    }
  }

  @override
  Future<void> close() {
    // Limpiar el controller al cerrar el cubit
    state.controller?.dispose();
    return super.close();
  }
}
