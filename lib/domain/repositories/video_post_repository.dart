import 'package:mux_videos_app/domain/entities/video_post.dart';

abstract class VideoPostRepository {
  //este metodo nos va a retornar una lista de videos solo
  //tiene que regresar un future que regresa una lista de videopost
  Future<List<VideoPost>> getFavoriteVideosByUser(String userId);

  Future<List<VideoPost>> getTrendingVideosByPage(int page);
}

