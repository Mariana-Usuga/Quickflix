import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickflix/cubit/movies_cubit.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String videoUrl;
  final String caption;

  const FullScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.caption,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  @override
  void initState() {
    // aqui vamos a inicializar el video
    super.initState();
    context.read<MoviesCubit>().initializeVideo(widget.videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoviesCubit, MoviesState>(
      builder: (context, state) {
        // ❌ ERROR
        if (state.videoError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  state.videoError!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<MoviesCubit>()
                        .initializeVideo(widget.videoUrl);
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // ⏳ LOADING
        if (!state.isVideoInitialized ||
            state.videoController == null ||
            !state.videoController!.value.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.amber,
            ),
          );
        }

        final controller = state.videoController!;

        // ▶️ VIDEO
        return GestureDetector(
          onTap: () {
            context.read<MoviesCubit>().togglePlay();
          },
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
        );
      },
    );
  }
}

/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String videoUrl;
  final String caption;
  final VoidCallback? onError;

  const FullScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.caption,
    this.onError,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  VideoPlayerController? controller;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isDisposing = false;

  @override
  void initState() {
    // aqui vamos a inicializar el video
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(FullScreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió la URL del video, reinicializar
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    // Si ya hay un controller, limpiarlo primero
    if (controller != null) {
      final oldController = controller;
      controller = null;
      try {
        await oldController?.dispose();
      } catch (e) {
        debugPrint('Error al limpiar controller anterior: $e');
      }
    }

    // Validar que la URL no esté vacía
    if (widget.videoUrl.isEmpty) {
      if (mounted && !_isDisposing) {
        setState(() {
          _errorMessage = 'URL del video vacía';
          _isInitialized = false;
        });
        widget.onError?.call();
      }
      debugPrint('Error: URL del video vacía');
      return;
    }

    // Resetear estado
    if (mounted && !_isDisposing) {
      setState(() {
        _isInitialized = false;
        _errorMessage = null;
      });
    }

    try {
      VideoPlayerController? newController;
      
      // Detectar si es un asset local o una URL de red
      if (widget.videoUrl.startsWith('http://') ||
          widget.videoUrl.startsWith('https://')) {
        // Es una URL de red (Mux, etc.)
        debugPrint('Inicializando video desde URL: ${widget.videoUrl}');
        newController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      } else {
        // Es un asset local
        debugPrint('Inicializando video desde asset: ${widget.videoUrl}');
        newController = VideoPlayerController.asset(widget.videoUrl);
      }

      // Verificar que el widget aún esté montado antes de continuar
      if (!mounted || _isDisposing) {
        await newController.dispose();
        return;
      }

      controller = newController;

      // Inicializar con timeout más largo para videos de red
      await controller!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              'Timeout al inicializar el video después de 30 segundos');
        },
      );

      // Verificar nuevamente que el widget esté montado después de la inicialización
      if (mounted && !_isDisposing && controller != null) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
        controller!
          ..setVolume(0)
          ..setLooping(true) //se repite infinitamente
          ..play();
        debugPrint('Video inicializado correctamente');
      } else {
        // Si el widget se desmontó durante la inicialización, limpiar
        await controller?.dispose();
        controller = null;
      }
    } catch (e) {
      if (mounted && !_isDisposing) {
        setState(() {
          _isInitialized = false;
          _errorMessage = 'Error: $e';
        });
        widget.onError?.call();
      }
      debugPrint('Error al inicializar el video: $e');
      debugPrint('URL del video: ${widget.videoUrl}');

      // Limpiar el controller si hay error
      try {
        await controller?.dispose();
      } catch (disposeError) {
        debugPrint('Error al limpiar controller en catch: $disposeError');
      }
      controller = null;
    }
  }

  //siempre debemos limpiar el controlador para que el video no se siga
  //reproduciendo a pesar de que ya no lo estemos viendo

  @override
  void dispose() {
    _isDisposing = true;
    final controllerToDispose = controller;
    controller = null;
    
    // Dispose del controller de forma asíncrona pero sin esperar
    controllerToDispose?.dispose().catchError((error) {
      debugPrint('Error al hacer dispose del controller: $error');
    });
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar error si hay uno
    if (_errorMessage != null) {
      return Center(
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _initializeVideo();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Mostrar loading si no está inicializado
    if (!_isInitialized ||
        controller == null ||
        !controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.amber,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (controller!.value.isPlaying) {
          controller!.pause();
        } else {
          controller!.play();
        }
      },
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller!.value.size.width,
            height: controller!.value.size.height,
            child: VideoPlayer(controller!),
          ),
        ),
      ),
    );
  }
}*/


/* NOTAS IMPORTANTES
  el page view no se deben cargar mas de tres vistas ya que son recuros de memoria no utilizados

el video player necesita un controllador , se maneja dentro de una statefull widget
ese controldor vadentro del estate 
un state full si tiene un ciclo de vida 
inicia initstate

 */

