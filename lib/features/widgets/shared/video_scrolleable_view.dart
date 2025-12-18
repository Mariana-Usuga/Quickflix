import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quickflix/models/video_post.dart';
import 'package:quickflix/features/widgets/shared/video_buttons.dart';
import 'package:quickflix/features/widgets/video/fullscreen_player.dart';

class VideoScrollableView extends StatelessWidget {
  final List<VideoPost> videos;

  const VideoScrollableView({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      //este widget nos permite hacer un scroll a pantalla completa es como dezplaxzarse entre pantallas
      scrollDirection: Axis.vertical,
      physics: BouncingScrollPhysics(),
      itemCount: videos
          .length, // para que se pueda desplazar por defecto esta propiedads lo permite
      itemBuilder: (context, index) {
        final VideoPost videoPost = videos[index];

        return Stack(
          //el stack es un widget que permite superponer unos sobre otros
          children: [
            //video player + gradientes
            SizedBox.expand(
                //esto es para asegurarnos de que el reproductor tome el tamaño de la pantalla
                child: FullScreenPlayer(
                  videoUrl: videoPost.videoUrl, 
                  caption: videoPost.caption,)
                  ),

            // botones
            Positioned(
                bottom: 40, right: 20, child: VideoButtons(video: videoPost))
          ],
        );
      },
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

