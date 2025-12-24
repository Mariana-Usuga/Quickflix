part of 'movies_cubit.dart';

enum LoadingStatus { initial, loading, success, failure }

class MoviesState {
  final List<VideoPost> videos;
  final VideoPost? selectedMovie;
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  /*final bool loading;
  final String? error;
  final dynamic content;
  final String? analysisId;*/

  const MoviesState({
    this.videos = const [],
    this.isLastPage = false,
    this.selectedMovie,
    this.limit = 10,
    this.offset = 0,
    this.isLoading = false,
  });

  MoviesState copyWith({
    List<VideoPost>? videos,
    VideoPost? selectedMovie,
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
  }) {
    return MoviesState(
      videos: videos ?? this.videos,
      selectedMovie: selectedMovie ?? this.selectedMovie,
      isLastPage: isLastPage ?? this.isLastPage,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
