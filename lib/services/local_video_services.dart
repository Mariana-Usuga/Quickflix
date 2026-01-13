import 'package:quickflix/shared/entities/profile.dart';
import 'package:quickflix/shared/entities/season.dart';
import 'package:quickflix/shared/models/title_model.dart';
import 'package:quickflix/shared/entities/video_title.dart';
import 'package:quickflix/shared/entities/episode.dart';
import 'package:quickflix/shared/models/episode_model.dart';
import 'package:quickflix/shared/models/profile_model.dart';
import 'package:quickflix/shared/models/season_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocalVideoServices {
  Future<List<VideoTitle>> getTrendingVideosByPage(int page) async {
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
      final List<VideoTitle> videos = (response as List)
          .map((video) => TitleModel.fromJson(video as Map<String, dynamic>)
              .toVideoPostEntity())
          .cast<VideoTitle>()
          .toList();

      return videos;
    } catch (e, stackTrace) {
      // Imprimir error completo para debugging
      print('Error al obtener videos de Supabase: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al obtener videos de Supabase: $e');
    }
  }

  Future<List<VideoTitle>> getVideosByFilter(
      {required String category, int page = 1}) async {
    const int pageSize = 10;

    try {
      dynamic query = Supabase.instance.client.from('titles').select();

      // Aplicamos la lógica de filtrado/ordenamiento de la base de datos
      switch (category) {
        case 'New':
          query = query.order('release_date', ascending: false);
          break;
        case 'Popular':
          query = query.order('views_count', ascending: false);
          break;
        case 'Ranking':
          query = query.order('rating', ascending: false);
          break;
        case 'Comedy':
          query = query.filter(
              'gender', 'eq', 'Comedy'); // Asegúrate que coincida con tu DB
          break;
        case 'Action':
          query = query.filter('gender', 'eq', 'Action');
          break;
        default: // 'All'
          query = query.order('created_at', ascending: false);
      }

      final response =
          await query.range((page - 1) * pageSize, page * pageSize - 1);

      final List<VideoTitle> videos = (response as List)
          .map((video) => TitleModel.fromJson(video).toVideoPostEntity())
          .toList();

      return videos;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<VideoTitle>> searchMoviesByQuery(String query) async {
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
      final List<VideoTitle> movies = (response as List)
          .map((item) => TitleModel.fromJson(item as Map<String, dynamic>)
              .toVideoPostEntity())
          .toList();

      return movies;
    } catch (e, stackTrace) {
      // Imprimir error completo para debugging
      print('Error al buscar películas en Supabase: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al buscar películas en Supabase: $e');
    }
  }

  /// Obtiene las temporadas según el title_id desde la tabla seasons
  Future<List<Season>> getSeasonsByTitleId(int titleId) async {
    try {
      // Obtener temporadas de Supabase filtradas por title_id
      final response = await Supabase.instance.client
          .from('seasons')
          .select()
          .eq('title_id', titleId)
          .order('season_number', ascending: true);

      // Convertir los datos de Supabase a Season
      final List<Season> seasons = (response as List)
          .map((season) => SeasonModel.fromJson(season as Map<String, dynamic>))
          .toList();

      return seasons;
    } catch (e, stackTrace) {
      // Imprimir error completo para debugging
      print('Error al obtener temporadas de Supabase: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al obtener temporadas de Supabase: $e');
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
  Future<List<VideoTitle>> getSavedVideosByProfileId(String profileId) async {
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
      final List<VideoTitle> videos = (response as List)
          .map((item) {
            // El join devuelve los datos de titles anidados
            final titleData = item['titles'] as Map<String, dynamic>?;
            if (titleData == null) return null;

            return TitleModel.fromJson(titleData).toVideoPostEntity();
          })
          .whereType<VideoTitle>()
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
        final List<VideoTitle> videos = [];
        for (final titleId in titleIds) {
          try {
            final titleResponse = await Supabase.instance.client
                .from('titles')
                .select()
                .eq('id', titleId)
                .single();

            final video =
                TitleModel.fromJson(Map<String, dynamic>.from(titleResponse))
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

  /// Guarda un título en la tabla user_saved
  /// profile_id es un UUID (String) y title_id es un int
  Future<void> saveTitle(String profileId, int titleId) async {
    try {
      await Supabase.instance.client.from('user_saved').insert({
        'profile_id': profileId,
        'title_id': titleId,
        'added_at': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      print('Error al guardar título en Supabase: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al guardar título: $e');
    }
  }

  /// Elimina un título guardado de la tabla user_saved
  /// profile_id es un UUID (String) y title_id es un int
  Future<void> removeSavedTitle(String profileId, int titleId) async {
    try {
      await Supabase.instance.client
          .from('user_saved')
          .delete()
          .eq('profile_id', profileId)
          .eq('title_id', titleId);
    } catch (e, stackTrace) {
      print('Error al eliminar título guardado de Supabase: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al eliminar título guardado: $e');
    }
  }

  /// Obtiene los videos en progreso según el profile_id desde la tabla user_progress
  /// profile_id es un UUID (String)
  Future<List<VideoTitle>> getWatchingVideosByProfileId(
      String profileId) async {
    try {
      // Intentar usar un join para obtener los títulos directamente desde user_progress
      final response =
          await Supabase.instance.client.from('user_progress').select('''
            title_id,
            titles!inner(*)
          ''').eq('profile_id', profileId);
      //.order('updated_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      // Extraer los datos de titles del join
      final List<VideoTitle> videos = (response as List)
          .map((item) {
            // El join devuelve los datos de titles anidados
            final titleData = item['titles'] as Map<String, dynamic>?;
            if (titleData == null) return null;

            return TitleModel.fromJson(titleData).toVideoPostEntity();
          })
          .whereType<VideoTitle>()
          .toList();

      return videos;
    } catch (e) {
      // Si el join falla, intentar método alternativo con consultas separadas
      try {
        // Obtener los title_id en progreso para el profile_id desde user_progress
        final progressResponse = await Supabase.instance.client
            .from('user_progress')
            .select('title_id')
            .eq('profile_id', profileId);
        //.order('updated_at', ascending: false);

        if (progressResponse.isEmpty) {
          return [];
        }

        // Extraer los title_id de los resultados
        final List<int> titleIds = (progressResponse as List)
            .map((item) => item['title_id'] as int? ?? 0)
            .where((id) => id > 0)
            .toList();

        if (titleIds.isEmpty) {
          return [];
        }

        // Obtener los títulos uno por uno o en lotes
        final List<VideoTitle> videos = [];
        for (final titleId in titleIds) {
          try {
            final titleResponse = await Supabase.instance.client
                .from('titles')
                .select()
                .eq('id', titleId)
                .single();

            final video =
                TitleModel.fromJson(Map<String, dynamic>.from(titleResponse))
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
        print('Error al obtener videos en progreso de Supabase: $e2');
        print('Stack trace: $stackTrace2');
        throw Exception('Error al obtener videos en progreso de Supabase: $e2');
      }
    }
  }

  Future<void> updateVideoProgress({
    required String profileId,
    required int titleId,
    required int episodeId,
    required int seconds,
  }) async {
    try {
      await Supabase.instance.client.from('user_progress').upsert({
        'profile_id': profileId,
        'title_id': titleId,
        'episode_id': episodeId,
        'current_time_seconds': seconds,
        'last_watched_at': DateTime.now().toIso8601String(),
        'is_finished': false, // Podrías validar si seconds > 90% del total
      });
    } catch (e) {
      print('Error guardando progreso: $e');
    }
  }

  /// Obtiene el perfil del usuario desde la tabla profiles
  /// profile_id es un UUID (String)
  Future<Profile> getProfileById(String profileId) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', profileId)
          .single();

      return ProfileModel.fromJson(response);
    } catch (e, stackTrace) {
      print('Error al obtener perfil de Supabase: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al obtener perfil: $e');
    }
  }

// En tu VideoServices

  /// Actualiza las coins del perfil del usuario
  /// profileId es un UUID (String)
  /// coinsToAdd es la cantidad de coins a agregar (sumar al valor actual)
  Future<void> addCoinsToProfile(String profileId, int coinsToAdd) async {
    try {
      // Primero obtener el perfil actual para obtener las coins actuales
      final currentProfile = await getProfileById(profileId);
      final newCoins = currentProfile.coins + coinsToAdd;

      // Actualizar las coins en Supabase
      await Supabase.instance.client
          .from('profiles')
          .update({'coins': newCoins}).eq('id', profileId);
    } catch (e, stackTrace) {
      print('Error al actualizar coins del perfil: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al actualizar coins: $e');
    }
  }

  /// Resta coins del perfil del usuario
  /// profileId es un UUID (String)
  /// coinsToSubtract es la cantidad de coins a restar (restar al valor actual)
  /// Retorna true si se pudo restar, false si no tiene suficientes coins
  Future<bool> subtractCoinsFromProfile(
      String profileId, int coinsToSubtract) async {
    try {
      // Primero obtener el perfil actual para obtener las coins actuales
      final currentProfile = await getProfileById(profileId);

      // Verificar si tiene suficientes coins
      if (currentProfile.coins < coinsToSubtract) {
        return false;
      }

      final newCoins = currentProfile.coins - coinsToSubtract;

      // Actualizar las coins en Supabase
      await Supabase.instance.client
          .from('profiles')
          .update({'coins': newCoins}).eq('id', profileId);

      return true;
    } catch (e, stackTrace) {
      print('Error al restar coins del perfil: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al restar coins: $e');
    }
  }
}
