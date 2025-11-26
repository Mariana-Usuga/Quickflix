/*es el origen de datos de donde nostros vamos a tomar los videos
aqui se crea la clase abstracta que va a permitir gobernar las implementaciones de los origenes de datos

*/

import 'package:mux_videos_app/domain/entities/video_post.dart';

abstract class VideoPostDatasource {
  //este metodo nos va a retornar una lista de videos solo
  //tiene que regresar un future que regresa una lista de videopost
  Future<List<VideoPost>> getFavoriteVideosByUser(String userId);

  Future<List<VideoPost>> getTrendingVideosByPage(int page);
}

