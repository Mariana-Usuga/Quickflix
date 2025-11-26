

import 'package:mux_videos_app/domain/datasources/video_posts_datsource.dart';
import 'package:mux_videos_app/domain/entities/video_post.dart';
import 'package:mux_videos_app/infraestructure/models/local_video_model.dart';
import 'package:mux_videos_app/share/local_video_post.dart';

class LocalVideoDatasource implements VideoPostDatasource{
  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async{
    await Future.delayed(const Duration(seconds: 2));

  /*para entender esta linea lo que hacemos es en la variable newvideos se va a crear un nuevo listado de videos los cuales los tomamos 
de un archivo muestra de json ,y lo converitmos a formato entidad para luego en una lista */
    final List<VideoPost> newvideos = videoPosts
        .map((video) => LocalVideoModel.fromJson(video).toVideoPostEntity())
        .toList(); //es el listado que tenemos en shared localvideospost
    
    return newvideos;
  }
  
}

