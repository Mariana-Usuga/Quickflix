part of 'titles_cubit.dart';

enum LoadingStatus { initial, loading, success, failure }

class MoviesState {
  final List<Episode> episodes;
  final List<Season> seasons;
  final List<VideoTitle> videos;
  final List<VideoTitle> savedVideos;
  final List<VideoTitle> watchingVideos;
  final VideoTitle? selectedMovie;
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final VideoPlayerController? videoController;
  final bool isVideoInitialized;
  final String? videoError;
  final bool showVideoButtons;
  final String? currentVideoUrl;

  const MoviesState({
    this.episodes = const [],
    this.seasons = const [],
    this.videos = const [],
    this.savedVideos = const [],
    this.watchingVideos = const [],
    this.isLastPage = false,
    this.selectedMovie,
    this.limit = 10,
    this.offset = 0,
    this.isLoading = false,
    this.videoController,
    this.isVideoInitialized = false,
    this.videoError,
    this.showVideoButtons = false,
    this.currentVideoUrl,
  });

  MoviesState copyWith({
    List<Episode>? episodes,
    List<Season>? seasons,
    List<VideoTitle>? videos,
    List<VideoTitle>? savedVideos,
    List<VideoTitle>? watchingVideos,
    VideoTitle? selectedMovie,
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    VideoPlayerController? videoController,
    bool? isVideoInitialized,
    String? videoError,
    bool? showVideoButtons,
    String? currentVideoUrl,
  }) {
    return MoviesState(
      episodes: episodes ?? this.episodes,
      seasons: seasons ?? this.seasons,
      videos: videos ?? this.videos,
      savedVideos: savedVideos ?? this.savedVideos,
      watchingVideos: watchingVideos ?? this.watchingVideos,
      selectedMovie: selectedMovie ?? this.selectedMovie,
      isLastPage: isLastPage ?? this.isLastPage,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      isLoading: isLoading ?? this.isLoading,
      videoController: videoController ?? this.videoController,
      isVideoInitialized: isVideoInitialized ?? this.isVideoInitialized,
      videoError: videoError,
      showVideoButtons: showVideoButtons ?? this.showVideoButtons,
      currentVideoUrl: currentVideoUrl ?? this.currentVideoUrl,
    );
  }

  // Getters para compatibilidad con fullscreen_player.dart
  VideoPlayerController? get controller => videoController;
  bool get isInitialized => isVideoInitialized;
  String? get errorMessage => videoError;
}
