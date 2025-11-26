/*IMPORTANTE
cuando definimos algo en domain obligatoriamente debe tener su modelo en la de infrestrucutura
el local_video_model es el que va a mappear la informacion de un video de la base de datos y el video_post es el que va a tener la informacion del video
 */

import 'package:mux_videos_app/domain/entities/video_post.dart';

class LocalVideoModel {
  final String name;
  final String videoUrl;
  final int likes;
  final int views;


  LocalVideoModel({
    //este es el constructor
    required this.name,
    required this.videoUrl,
    this.likes = 0,
    this.views= 0,
  });

  factory LocalVideoModel.fromJson(Map<String, dynamic> json) =>
      LocalVideoModel(
        name: json['name'] ?? 'no name', //esto es por si no viene el nombre desde el json
        videoUrl: json['videoUrl'],
        likes: json['likes'] ?? 0,
        views: json['views'] ?? 0,
      );


  Map<String, dynamic> toJson() => {
        'name': name,
        'videoUrl': videoUrl,
        'likes': likes,
        'views': views,
      };

  VideoPost toVideoPostEntity() => VideoPost(
        caption: name,
        videoUrl: videoUrl,
        likes: likes,
        views: views,
        
      );
}

