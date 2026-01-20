import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/usecases/get_upcoming_movies_usecase.dart';

/// Provider for managing movie state with pagination
class MovieProvider extends ChangeNotifier {
  final GetUpcomingMoviesUseCase getUpcomingMoviesUseCase;
  static const int moviesPerPage = 6;

  MovieProvider(this.getUpcomingMoviesUseCase);

  List<MovieEntity> _movies = [];
  List<MovieEntity> _allMovies = []; // Store all loaded movies from API
  bool _isLoading = false;
  bool _isLoadingMore = false;
  Failure? _error;
  int _currentPage = 1;
  int _displayedCount = 0; // Number of movies currently displayed
  bool _hasMore = true;

  /// Get list of movies (limited to current page)
  List<MovieEntity> get movies => _movies;

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get loading more state
  bool get isLoadingMore => _isLoadingMore;

  /// Get error state
  Failure? get error => _error;

  /// Check if there's an error
  bool get hasError => _error != null;

  /// Get error message
  String get errorMessage => _error?.message ?? '';

  /// Check if there are more movies to load
  bool get hasMore => _hasMore || _displayedCount < _allMovies.length;

  /// Load upcoming movies (initial load - first 6 movies)
  Future<void> loadUpcomingMovies() async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _displayedCount = 0;
    _hasMore = true;
    _allMovies = [];
    notifyListeners();

    final result = await getUpcomingMoviesUseCase(page: _currentPage);

    result.when(
      success: (pagination) {
        _allMovies = pagination.movies;
        _hasMore = pagination.hasMore;
        _currentPage = pagination.currentPage;
        
        // Show first 6 movies
        _displayedCount = moviesPerPage;
        _movies = _allMovies.take(_displayedCount).toList();
        
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      error: (failure) {
        _isLoading = false;
        _error = failure;
        _movies = [];
        _allMovies = [];
        _displayedCount = 0;
        notifyListeners();
      },
    );
  }

  /// Load more movies (pagination)
  Future<void> loadMoreMovies() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    // Check if we have more movies in the current page's data
    if (_displayedCount < _allMovies.length) {
      // Show next 6 movies from already loaded data
      _displayedCount = (_displayedCount + moviesPerPage).clamp(0, _allMovies.length);
      _movies = _allMovies.take(_displayedCount).toList();
      
      // Check if we need to load next page
      if (_displayedCount >= _allMovies.length) {
        // We've shown all movies from current page, check if there are more pages
        // This will be handled by checking _hasMore from the last API response
      }
      
      _isLoadingMore = false;
      notifyListeners();
      return;
    }

    // Load next page from API
    final nextPage = _currentPage + 1;
    final result = await getUpcomingMoviesUseCase(page: nextPage);

    result.when(
      success: (pagination) {
        _allMovies.addAll(pagination.movies);
        _hasMore = pagination.hasMore;
        _currentPage = pagination.currentPage;
        
        // Show next 6 movies
        _displayedCount = (_displayedCount + moviesPerPage).clamp(0, _allMovies.length);
        _movies = _allMovies.take(_displayedCount).toList();
        
        _isLoadingMore = false;
        _error = null;
        notifyListeners();
      },
      error: (failure) {
        _isLoadingMore = false;
        _error = failure;
        notifyListeners();
      },
    );
  }

  /// Refresh movies
  Future<void> refreshMovies() async {
    await loadUpcomingMovies();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
