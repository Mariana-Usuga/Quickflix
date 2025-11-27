import 'package:mux_videos_app/domain/datasources/video_posts_datsource.dart';
import 'package:mux_videos_app/domain/entities/video_post.dart';
import 'package:mux_videos_app/infraestructure/models/local_video_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocalVideoDatasource implements VideoPostDatasource {
  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    const int pageSize = 10; // Cantidad de videos por página

    try {
      // Obtener videos de Supabase con paginación
      // Nota: Si obtienes un array vacío, verifica las políticas RLS en Supabase
      final response = await Supabase.instance.client
          .from('mux_videos')
          .select()
          .order('created_at', ascending: false)
          .range((page - 1) * pageSize, page * pageSize - 1);

      // Convertir los datos de Supabase a VideoPost
      final List<VideoPost> videos = (response as List)
          .map((video) =>
              LocalVideoModel.fromJson(video as Map<String, dynamic>)
                  .toVideoPostEntity())
          .toList();

      return videos;
    } catch (e, stackTrace) {
      // Imprimir error completo para debugging
      print('Error al obtener videos de Supabase: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al obtener videos de Supabase: $e');
    }
  }
}
