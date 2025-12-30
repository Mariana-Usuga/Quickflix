import 'package:quickflix/models/local_video_model.dart';
import 'package:quickflix/models/video_post.dart';
import 'package:quickflix/models/movie.dart';
import 'package:quickflix/models/episodes.dart';
import 'package:quickflix/models/episode_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocalVideoServices {
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    const int pageSize = 10; // Cantidad de videos por página

    try {
      // Obtener videos de Supabase con paginación
      // Nota: Si obtienes un array vacío, verifica las políticas RLS en Supabase
      final response = await Supabase.instance.client
          .from('titles')
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
          .from('titles')
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

  Future<List<Episode>> getEpisodesByTitleId(int titleId) async {
    try {
      // Obtener episodios de Supabase filtrados por title_id
      final response = await Supabase.instance.client
          .from('episodes')
          .select()
          .eq('title_id', titleId)
          .order('episode_number', ascending: true);

      // Convertir los datos de Supabase a Episode
      final List<Episode> episodes = (response as List)
          .map((episode) =>
              EpisodeModel.fromJson(episode as Map<String, dynamic>)
                  .toEpisodeEntity())
          .toList();

      return episodes;
    } catch (e, stackTrace) {
      // Imprimir error completo para debugging
      print('Error al obtener episodios de Supabase: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al obtener episodios de Supabase: $e');
    }
  }

  /// Obtiene los videos guardados según el profile_id desde la tabla user_saved
  /// profile_id es un UUID (String)
  Future<List<VideoPost>> getSavedVideosByProfileId(String profileId) async {
    try {
      // Usar un join para obtener los títulos directamente desde user_saved
      // Asumiendo que hay una relación entre user_saved y titles
      final response = await Supabase.instance.client
          .from('user_saved')
          .select('''
            title_id,
            titles!inner(*)
          ''')
          .eq('profile_id', profileId)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      // Extraer los datos de titles del join
      final List<VideoPost> videos = (response as List)
          .map((item) {
            // El join devuelve los datos de titles anidados
            final titleData = item['titles'] as Map<String, dynamic>?;
            if (titleData == null) return null;

            return LocalVideoModel.fromJson(titleData).toVideoPostEntity();
          })
          .whereType<VideoPost>()
          .toList();

      return videos;
    } catch (e) {
      // Si el join falla, intentar método alternativo con consultas separadas
      try {
        // Obtener los title_id guardados para el profile_id desde user_saved
        final savedResponse = await Supabase.instance.client
            .from('user_saved')
            .select('title_id')
            .eq('profile_id', profileId)
            .order('created_at', ascending: false);

        if (savedResponse.isEmpty) {
          return [];
        }

        // Extraer los title_id de los resultados
        final List<int> titleIds = (savedResponse as List)
            .map((item) => item['title_id'] as int? ?? 0)
            .where((id) => id > 0)
            .toList();

        if (titleIds.isEmpty) {
          return [];
        }

        // Obtener los títulos uno por uno o en lotes
        final List<VideoPost> videos = [];
        for (final titleId in titleIds) {
          try {
            final titleResponse = await Supabase.instance.client
                .from('titles')
                .select()
                .eq('id', titleId)
                .single();

            final video = LocalVideoModel.fromJson(
                    Map<String, dynamic>.from(titleResponse))
                .toVideoPostEntity();
            videos.add(video);
          } catch (_) {
            // Continuar con el siguiente si hay error
            continue;
          }
        }

        return videos;
      } catch (e2, stackTrace2) {
        // Imprimir error completo para debugging
        print('Error al obtener videos guardados de Supabase: $e2');
        print('Stack trace: $stackTrace2');
        throw Exception('Error al obtener videos guardados de Supabase: $e2');
      }
    }
  }
}
