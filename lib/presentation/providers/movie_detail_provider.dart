import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/movie_detail_entity.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/usecases/get_movie_details_usecase.dart';
import '../../domain/usecases/get_movie_videos_usecase.dart';

/// Provider for managing movie detail state
class MovieDetailProvider extends ChangeNotifier {
  final GetMovieDetailsUseCase getMovieDetailsUseCase;
  final GetMovieVideosUseCase getMovieVideosUseCase;

  MovieDetailProvider({
    required this.getMovieDetailsUseCase,
    required this.getMovieVideosUseCase,
  });

  MovieDetailEntity? _movieDetail;
  List<VideoEntity> _videos = [];
  VideoEntity? _trailer;
  bool _isLoading = false;
  bool _isLoadingVideos = false;
  Failure? _error;

  /// Get movie detail
  MovieDetailEntity? get movieDetail => _movieDetail;

  /// Get videos
  List<VideoEntity> get videos => _videos;

  /// Get trailer
  VideoEntity? get trailer => _trailer;

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get loading videos state
  bool get isLoadingVideos => _isLoadingVideos;

  /// Get error state
  Failure? get error => _error;

  /// Check if there's an error
  bool get hasError => _error != null;

  /// Get error message
  String get errorMessage => _error?.message ?? '';

  /// Load movie details
  Future<void> loadMovieDetails(int movieId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getMovieDetailsUseCase(movieId);

    result.when(
      success: (detail) {
        _movieDetail = detail;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      error: (failure) {
        _isLoading = false;
        _error = failure;
        notifyListeners();
      },
    );
  }

  /// Load movie videos
  Future<void> loadMovieVideos(int movieId) async {
    _isLoadingVideos = true;
    notifyListeners();

    final result = await getMovieVideosUseCase(movieId);

    result.when(
      success: (videos) {
        _videos = videos;
        // Prefer playable (YouTube, Vimeo, Dailymotion) trailers, then any playable video
        final playable = videos.where((v) => v.isPlayable).toList();
        try {
          _trailer = playable.firstWhere((v) => v.isTrailer);
        } catch (_) {
          _trailer = playable.isNotEmpty ? playable.first : null;
        }
        if (_trailer == null && videos.isNotEmpty) {
          // Fallback: first trailer or first video (may open externally only)
          try {
            _trailer = videos.firstWhere((v) => v.isTrailer);
          } catch (_) {
            _trailer = videos.first;
          }
        }
        _isLoadingVideos = false;
        notifyListeners();
      },
      error: (failure) {
        _isLoadingVideos = false;
        _videos = [];
        _trailer = null;
        notifyListeners();
      },
    );
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
