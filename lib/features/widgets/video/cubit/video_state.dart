part of 'video_cubit.dart';

class VideoState {
  final VideoPlayerController? controller;
  final bool isInitialized;
  final String? errorMessage;
  final String? currentVideoUrl;

  const VideoState({
    this.controller,
    this.isInitialized = false,
    this.errorMessage,
    this.currentVideoUrl,
  });

  VideoState copyWith({
    VideoPlayerController? controller,
    bool? isInitialized,
    String? errorMessage,
    String? currentVideoUrl,
  }) {
    return VideoState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
      currentVideoUrl: currentVideoUrl ?? this.currentVideoUrl,
    );
  }
}
