import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String videoUrl;
  final String caption;

  const FullScreenPlayer(
      {super.key, required this.videoUrl, required this.caption});

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  VideoPlayerController? controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    // aqui vamos a inicializar el video
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // Validar que la URL no esté vacía
    if (widget.videoUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = 'URL del video vacía';
          _isInitialized = false;
        });
      }
      debugPrint('Error: URL del video vacía');
      return;
    }

    try {
      // Detectar si es un asset local o una URL de red
      if (widget.videoUrl.startsWith('http://') || widget.videoUrl.startsWith('https://')) {
        // Es una URL de red (Mux, etc.)
        debugPrint('Inicializando video desde URL: ${widget.videoUrl}');
        controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      } else {
        // Es un asset local
        debugPrint('Inicializando video desde asset: ${widget.videoUrl}');
        controller = VideoPlayerController.asset(widget.videoUrl);
      }

      // Inicializar con timeout
      await controller!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Timeout al inicializar el video');
        },
      );

      if (mounted && controller != null) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
        controller!
          ..setVolume(0)
          ..setLooping(true) //se repite infinitamente
          ..play();
        debugPrint('Video inicializado correctamente');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _errorMessage = 'Error: $e';
        });
      }
      debugPrint('Error al inicializar el video: $e');
      debugPrint('URL del video: ${widget.videoUrl}');
      
      // Limpiar el controller si hay error
      await controller?.dispose();
      controller = null;
    }
  }

  //siempre debemos limpiar el controlador para que el video no se siga
  //reproduciendo a pesar de que ya no lo estemos viendo

  @override
  void dispose() {
    controller?.dispose();
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
    if (!_isInitialized || controller == null || !controller!.value.isInitialized) {
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
}


/* NOTAS IMPORTANTES
  el page view no se deben cargar mas de tres vistas ya que son recuros de memoria no utilizados

el video player necesita un controllador , se maneja dentro de una statefull widget
ese controldor vadentro del estate 
un state full si tiene un ciclo de vida 
inicia initstate

 */

