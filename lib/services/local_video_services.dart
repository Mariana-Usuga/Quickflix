import 'package:quickflix/models/local_video_model.dart';
import 'package:quickflix/models/video_post.dart';
import 'package:quickflix/models/movie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocalVideoServices {
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
          .cast<VideoPost>()
          .toList();

      return videos;
    } catch (e, stackTrace) {
      // Imprimir error completo para debugging
      print('Error al obtener videos de Supabase: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al obtener videos de Supabase: $e');
    }
  }

  Future<List<Movie>> searchMoviesByQuery(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      // Buscar en la tabla content_analysis por título
      final response = await Supabase.instance.client
          .from('mux_videos')
          .select()
          .ilike('title', '%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      // Convertir los datos de Supabase a Movie
      final List<Movie> movies = (response as List)
          .map(
              (item) => Movie.fromContentAnalysis(item as Map<String, dynamic>))
          .toList();

      return movies;
    } catch (e, stackTrace) {
      // Imprimir error completo para debugging
      print('Error al buscar películas en Supabase: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al buscar películas en Supabase: $e');
    }
  }
}
