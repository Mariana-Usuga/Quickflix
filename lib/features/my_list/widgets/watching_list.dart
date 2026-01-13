import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quickflix/shared/cubits/titles/titles_cubit.dart';
import 'package:quickflix/features/widgets/shared/move_item.dart';
import 'package:quickflix/shared/entities/video_title.dart';

/// Widget que muestra la lista de videos en reproducción
class WatchingList extends StatelessWidget {
  final String profileId;

  const WatchingList({
    super.key,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoviesCubit, MoviesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.watchingVideos.isEmpty) {
          return const Center(
            child: Text(
              'No videos in progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: state.watchingVideos.length,
          itemBuilder: (context, index) {
            final videoTitle = state.watchingVideos[index];

            return MovieItem(
              movie: videoTitle,
              profileId: profileId,
              onMovieSelected: (BuildContext context, VideoTitle movie) {
                // Navegar a la pantalla de detalles del video
                context.push('/home/0/movie/${movie.id}');
              },
            );
          },
        );
      },
    );
  }
}

