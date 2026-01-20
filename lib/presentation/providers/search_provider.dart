import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/genre_entity.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/pagination_entity.dart';
import '../../domain/usecases/get_genres_usecase.dart';
import '../../domain/usecases/search_movies_usecase.dart';
import '../../domain/usecases/get_movies_by_genre_usecase.dart';

/// Provider for managing search state
class SearchProvider extends ChangeNotifier {
  final SearchMoviesUseCase searchMoviesUseCase;
  final GetGenresUseCase getGenresUseCase;
  final GetMoviesByGenreUseCase getMoviesByGenreUseCase;

  SearchProvider({
    required this.searchMoviesUseCase,
    required this.getGenresUseCase,
    required this.getMoviesByGenreUseCase,
  });

  List<MovieEntity> _searchResults = [];
  List<GenreEntity> _genres = [];
  Map<int, String> _genreImageMap = {}; // Genre ID -> Backdrop Image URL
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isLoadingGenres = false;
  Failure? _error;
  Map<int, String> _genreMap = {};

  /// Get search results
  List<MovieEntity> get searchResults => _searchResults;

  /// Get genres
  List<GenreEntity> get genres => _genres;

  /// Get search query
  String get searchQuery => _searchQuery;

  /// Get searching state
  bool get isSearching => _isSearching;

  /// Get loading genres state
  bool get isLoadingGenres => _isLoadingGenres;

  /// Get error state
  Failure? get error => _error;

  /// Check if there's an error
  bool get hasError => _error != null;

  /// Get error message
  String get errorMessage => _error?.message ?? '';

  /// Get genre name by ID
  String? getGenreName(int? genreId) {
    if (genreId == null) return null;
    return _genreMap[genreId];
  }

  /// Get genre names for movie
  String getGenreNames(MovieEntity movie) {
    if (movie.genreIds == null || movie.genreIds!.isEmpty) {
      return '';
    }
    final names = movie.genreIds!
        .map((id) => _genreMap[id] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    return names.join(', ');
  }

  /// Load genres
  Future<void> loadGenres() async {
    if (_genres.isNotEmpty) return; // Already loaded

    _isLoadingGenres = true;
    notifyListeners();

    final result = await getGenresUseCase();

    result.when(
      success: (genres) {
        _genres = genres;
        _genreMap = {for (var genre in genres) genre.id: genre.name};
        _isLoadingGenres = false;
        _error = null;
        notifyListeners();
        
        // Load images for genres asynchronously
        _loadGenreImages(genres);
      },
      error: (failure) {
        _isLoadingGenres = false;
        _error = failure;
        notifyListeners();
      },
    );
  }

  /// Search movies
  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _error = null;
    _searchQuery = query;
    notifyListeners();

    final result = await searchMoviesUseCase(query);

    result.when(
      success: (pagination) {
        _searchResults = pagination.movies;
        _isSearching = false;
        _error = null;
        notifyListeners();
      },
      error: (failure) {
        _isSearching = false;
        _error = failure;
        _searchResults = [];
        notifyListeners();
      },
    );
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _error = null;
    notifyListeners();
  }

  /// Load images for genres (fetch first popular movie for each genre)
  Future<void> _loadGenreImages(List<GenreEntity> genres) async {
    for (final genre in genres) {
      try {
        final result = await getMoviesByGenreUseCase(genre.id);
        result.when(
          success: (pagination) {
            if (pagination.movies.isNotEmpty) {
              final firstMovie = pagination.movies.first;
              if (firstMovie.backdropImageUrl.isNotEmpty) {
                _genreImageMap[genre.id] = firstMovie.backdropImageUrl;
                notifyListeners();
              }
            }
          },
          error: (_) {
            // Silently fail - keep placeholder
          },
        );
      } catch (e) {
        // Silently fail - keep placeholder
      }
    }
  }

  /// Get image URL for genre
  String? getGenreImageUrl(int genreId) {
    return _genreImageMap[genreId];
  }

  /// Get movies by genre (for use in GenreMoviesScreen)
  Future<Result<PaginationEntity>> getMoviesByGenre(int genreId, {int page = 1}) async {
    return await getMoviesByGenreUseCase(genreId, page: page);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
