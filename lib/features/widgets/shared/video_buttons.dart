import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quickflix/models/video_post.dart';

import '../../../core/utils/text_formatter.dart';

class VideoButtons extends StatelessWidget {
  final VideoPost video;

  const VideoButtons({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CustomIconButton(
          value: video.likes,
          color: Colors.red,
          iconData: Icons.favorite,
        ),
        const SizedBox(height: 20),
        _CustomIconButton(
          value: video.likes,
          iconData: Icons.remove_red_eye_outlined,
        ),
        const SizedBox(height: 20),
        SpinPerfect(
          //ANIMACION DEL PAQUETE DE FERNANADO animate_do
          infinite: true,
          duration: const Duration(seconds: 2),
          child: _CustomIconButton(
            value: 0,
            iconData: Icons.play_circle_fill_outlined,
          ),
        )
      ],
    );
  }
}

class _CustomIconButton extends StatelessWidget {
  final int value;
  final IconData iconData;
  final Color? color;

  const _CustomIconButton({
      required this.value,
      required this.iconData,
      this.color = Colors.white});

  //iconColor})
  //: color = iconColor ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
            onPressed: () {}, icon: Icon(iconData, color: color, size: 30)),
        if (value > 0)
          Text('${TextFormatter.textReadeableNumber(value.toDouble())}'),
      ],
    );
  }
}

