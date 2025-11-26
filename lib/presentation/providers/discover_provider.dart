import 'package:flutter/material.dart';
import 'package:mux_videos_app/domain/entities/video_post.dart';
import 'package:mux_videos_app/domain/repositories/video_post_repository.dart';

/*ESTA CLASE SOLO TIENE LA RESPONSABILIDAD DE PASAR LA INF A LOS WIDGETS , NADA DE MAPPEAR NI DE CONVERTIR  */

class DiscoverProvider extends ChangeNotifier {
  //el repositorio ya va a asaber que origen de datos le vamos a dar a el
  final VideoPostRepository videosRepository;

  //TODO: repository: sera quin va a permitir lanzar las peticiones respectivas
  //datasource: es la fuente de la data en la cual vamos a tener varias fuentes como local , internet, jsonlocal etc

  bool initialLoading = true;
  //esto con la finalidad de iniciar la cara de videos ya que la primera vez que se inicie el provider no va a tener videos

  List<VideoPost> videos = [];

  DiscoverProvider({required this.videosRepository});

  Future<void> loadNextPage() async {
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

    final newVideos = await videosRepository.getTrendingVideosByPage(1);

    videos.addAll(newVideos);
    initialLoading = false;
    notifyListeners();
  }
}

