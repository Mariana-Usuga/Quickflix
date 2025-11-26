import 'package:flutter/material.dart';
import 'package:mux_videos_app/presentation/widgets/video/video_background.dart';
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
  late VideoPlayerController controller;

  @override
  void initState() {
    // aqui vamos a inicializar el video
    super.initState();
    controller = VideoPlayerController.asset(
        widget.videoUrl) //esto significa que lo vamos a leer desde un asset
      ..setVolume(0)
      ..setLooping(true) //se repite infinitamente
      ..play();
  }

  //siempre debemos limpiar el controlador para que el video no se siga
  //reproduciendo a pesar de que ya no lo estemos viendo

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //directamente no tenemos acceso a las propiedades del constructor entocnes slo hacemos asi
    //widget.caption;

    return FutureBuilder(
      future: controller.initialize(),
      builder: (context, snapshot) {
        //vamos a vlaidar que el circular progres solo este en la inicializacion de los videos
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.amber,
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            if (controller.value.isPlaying) {
              controller.pause();
              return;
            }
            controller.play();
          },
          child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: Stack(
                children: [
                  VideoPlayer(controller),

                  //gradiente
                  VideoBackground(
                    stops: const [0.8, 1.0],
                  ),

                  //texto
                  Positioned(
                    bottom: 50,
                    left: 20,
                    child: _VideoCaption(caption: widget.caption),
                  )
                ],
              )),
        );
      },
    );
  }
}

class _VideoCaption extends StatelessWidget {
  final String caption;

  const _VideoCaption({required this.caption});

  @override
  Widget build(BuildContext context) {
    final Size = MediaQuery.of(context).size;
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return SizedBox(
      width: Size.width * 0.6,
      child: Text(caption, maxLines: 2, style: titleStyle),
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

