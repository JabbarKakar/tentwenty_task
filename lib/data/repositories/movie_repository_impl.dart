import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/genre_entity.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/movie_detail_entity.dart';
import '../../domain/entities/pagination_entity.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_datasource.dart';

/// Implementation of MovieRepository
class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<PaginationEntity>> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await remoteDataSource.getUpcomingMovies(page: page);

      if (response.results.isEmpty) {
        return const Error(NullFailure('No upcoming movies found'));
      }

      final movies = response.results.map((model) => model.toEntity()).toList();
      final paginationEntity = PaginationEntity(
        movies: movies,
        currentPage: response.page,
        totalPages: response.totalPages,
        hasMore: response.page < response.totalPages,
      );
      return Success(paginationEntity);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on NoInternetException catch (e) {
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, e.statusCode));
    } on TimeoutException catch (e) {
      return Error(TimeoutFailure(e.message));
    } on ParsingException catch (e) {
      return Error(ParsingFailure(e.message));
    } on NullException catch (e) {
      return Error(NullFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get upcoming movies: $e'));
    }
  }

  @override
  Future<Result<PaginationEntity>> searchMovies(String query, {int page = 1}) async {
    try {
      if (query.trim().isEmpty) {
        return const Error(NullFailure('Search query cannot be empty'));
      }

      final response = await remoteDataSource.searchMovies(query, page: page);

      if (response.results.isEmpty) {
        return const Error(NullFailure('No movies found'));
      }

      final movies = response.results.map((model) => model.toEntity()).toList();
      final paginationEntity = PaginationEntity(
        movies: movies,
        currentPage: response.page,
        totalPages: response.totalPages,
        hasMore: response.page < response.totalPages,
      );
      return Success(paginationEntity);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on NoInternetException catch (e) {
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, e.statusCode));
    } on TimeoutException catch (e) {
      return Error(TimeoutFailure(e.message));
    } on ParsingException catch (e) {
      return Error(ParsingFailure(e.message));
    } on NullException catch (e) {
      return Error(NullFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to search movies: $e'));
    }
  }

  @override
  Future<Result<List<GenreEntity>>> getGenres() async {
    try {
      final genres = await remoteDataSource.getGenres();

      if (genres.isEmpty) {
        return const Error(NullFailure('No genres found'));
      }

      final genreEntities = genres.map((model) => model.toEntity()).toList();
      return Success(genreEntities);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on NoInternetException catch (e) {
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, e.statusCode));
    } on TimeoutException catch (e) {
      return Error(TimeoutFailure(e.message));
    } on ParsingException catch (e) {
      return Error(ParsingFailure(e.message));
    } on NullException catch (e) {
      return Error(NullFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get genres: $e'));
    }
  }

  @override
  Future<Result<PaginationEntity>> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final response = await remoteDataSource.getMoviesByGenre(genreId, page: page);

      if (response.results.isEmpty) {
        return const Error(NullFailure('No movies found for this genre'));
      }

      final movies = response.results.map((model) => model.toEntity()).toList();
      final paginationEntity = PaginationEntity(
        movies: movies,
        currentPage: response.page,
        totalPages: response.totalPages,
        hasMore: response.page < response.totalPages,
      );
      return Success(paginationEntity);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on NoInternetException catch (e) {
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, e.statusCode));
    } on TimeoutException catch (e) {
      return Error(TimeoutFailure(e.message));
    } on ParsingException catch (e) {
      return Error(ParsingFailure(e.message));
    } on NullException catch (e) {
      return Error(NullFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get movies by genre: $e'));
    }
  }

  @override
  Future<Result<MovieDetailEntity>> getMovieDetails(int movieId) async {
    try {
      final detail = await remoteDataSource.getMovieDetails(movieId);
      return Success(detail.toEntity());
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on NoInternetException catch (e) {
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, e.statusCode));
    } on TimeoutException catch (e) {
      return Error(TimeoutFailure(e.message));
    } on ParsingException catch (e) {
      return Error(ParsingFailure(e.message));
    } on NullException catch (e) {
      return Error(NullFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get movie details: $e'));
    }
  }

  @override
  Future<Result<List<VideoEntity>>> getMovieVideos(int movieId) async {
    try {
      final response = await remoteDataSource.getMovieVideos(movieId);
      final videos = response.results.map((model) => model as VideoEntity).toList();
      if (videos.isEmpty) {
        return const Error(NullFailure('No videos found'));
      }
      return Success(videos);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on NoInternetException catch (e) {
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, e.statusCode));
    } on TimeoutException catch (e) {
      return Error(TimeoutFailure(e.message));
    } on ParsingException catch (e) {
      return Error(ParsingFailure(e.message));
    } on NullException catch (e) {
      return Error(NullFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to get movie videos: $e'));
    }
  }
}
