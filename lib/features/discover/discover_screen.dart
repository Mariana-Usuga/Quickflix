import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickflix/cubit/movies_cubit.dart';
import 'package:quickflix/features/widgets/shared/video_scrolleable_view.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<MoviesCubit>();
      if (cubit.state.episodes.isEmpty) {
        cubit.loadEpisodes(3);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MoviesCubit, MoviesState>(
        builder: (context, state) {
          /*if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }*/

          return VideoScrollableView(videos: state.episodes);
        },
      ),
    );
  }
}
