import '../../core/utils/result.dart';
import '../entities/genre_entity.dart';
import '../entities/movie_entity.dart';
import '../entities/movie_detail_entity.dart';
import '../entities/pagination_entity.dart';
import '../entities/video_entity.dart';

/// Repository interface for movie operations
abstract class MovieRepository {
  /// Get upcoming movies with pagination
  Future<Result<PaginationEntity>> getUpcomingMovies({int page = 1});

  /// Search movies
  Future<Result<PaginationEntity>> searchMovies(String query, {int page = 1});

  /// Get movie genres
  Future<Result<List<GenreEntity>>> getGenres();

  /// Get movies by genre
  Future<Result<PaginationEntity>> getMoviesByGenre(int genreId, {int page = 1});

  /// Get movie details
  Future<Result<MovieDetailEntity>> getMovieDetails(int movieId);

  /// Get movie videos/trailers
  Future<Result<List<VideoEntity>>> getMovieVideos(int movieId);
}
