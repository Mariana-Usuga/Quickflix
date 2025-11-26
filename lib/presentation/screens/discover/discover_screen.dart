import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mux_videos_app/presentation/providers/discover_provider.dart';
import 'package:mux_videos_app/presentation/widgets/shared/video_scrolleable_view.dart';

class DiscoverScreen extends StatelessWidget {

  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
//necesitamos hacer la referencia al provider el cual ya tiene cargada la infromacion
    final discoverProvider = context.watch<DiscoverProvider>();

    return Scaffold(
        body: discoverProvider.initialLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : VideoScrollableView(videos: discoverProvider.videos)
            );
  }
}

