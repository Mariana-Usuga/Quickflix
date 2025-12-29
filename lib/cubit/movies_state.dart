part of 'movies_cubit.dart';

enum LoadingStatus { initial, loading, success, failure }

class MoviesState {
  final List<Episode> episodes;
  final List<VideoPost> videos;
  final VideoPost? selectedMovie;
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final VideoPlayerController? videoController;
  final bool isVideoInitialized;
  final String? videoError;
  final bool showVideoButtons;

  const MoviesState({
    this.episodes = const [],
    this.videos = const [],
    this.isLastPage = false,
    this.selectedMovie,
    this.limit = 10,
    this.offset = 0,
    this.isLoading = false,
    this.videoController,
    this.isVideoInitialized = false,
    this.videoError,
    this.showVideoButtons = false,
  });

  MoviesState copyWith({
    List<Episode>? episodes,
    List<VideoPost>? videos,
    VideoPost? selectedMovie,
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    VideoPlayerController? videoController,
    bool? isVideoInitialized,
    String? videoError,
    bool? showVideoButtons,
  }) {
    return MoviesState(
      episodes: episodes ?? this.episodes,
      videos: videos ?? this.videos,
      selectedMovie: selectedMovie ?? this.selectedMovie,
      isLastPage: isLastPage ?? this.isLastPage,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      isLoading: isLoading ?? this.isLoading,
      videoController: videoController ?? this.videoController,
      isVideoInitialized: isVideoInitialized ?? this.isVideoInitialized,
      videoError: videoError,
      showVideoButtons: showVideoButtons ?? this.showVideoButtons,
    );
  }
}
