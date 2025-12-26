import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickflix/cubit/movies_cubit.dart';
import 'package:quickflix/providers/discover_provider.dart';
import 'package:quickflix/features/widgets/shared/video_scrolleable_view.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videosBloc = context.read<MoviesCubit>();

    return Scaffold(
        /*body: discoverProvider.initialLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            :*/
        body: VideoScrollableView(videos: videosBloc.state.videos));
  }
}
