import 'package:flutter/material.dart';
import 'package:quickflix/models/video_post.dart';
import 'package:quickflix/services/local_video_services.dart';

class DiscoverProvider extends ChangeNotifier {
  final LocalVideoServices localVideoServices;
  bool initialLoading = true;

  List<VideoPost> videos = [];

  DiscoverProvider({required this.localVideoServices});

  Future<void> loadNextPage() async {
    try {
      // todo : cargar videos

      //vamos a simular una comunicacion http asincrona
      /*este metodo espera 2 segudos carga los videosy los añade a la lista  */
      //await Future.delayed(const Duration(seconds: 2));

      /*para entender esta linea lo que hacemos es en la variable newvideos se va a crear un nuevo listado de videos los cuales los tomamos 
  de un archivo muestra de json ,y lo converitmos a formato entidad para luego en una lista */
      /* final List<VideoPost> newvideos = videoPosts
          .map((video) => LocalVideoModel.fromJson(video).toVideoPostEntity())
          .toList(); //es el listado que tenemos en shared localvideospost
    */

      final newVideos = await localVideoServices.getTrendingVideosByPage(1);

      videos.addAll(newVideos);
      initialLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      // Manejar errores para evitar crashes
      print('Error al cargar videos: $e');
      print('Stack trace: $stackTrace');
      initialLoading = false;
      // Mantener los videos existentes si hay error
      notifyListeners();
    }
  }
}
