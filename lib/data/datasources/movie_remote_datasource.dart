import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/movie_model.dart';
import '../models/genre_model.dart';
import '../models/movie_detail_model.dart';
import '../models/video_model.dart';

/// Remote data source interface
abstract class MovieRemoteDataSource {
  Future<MovieResponseModel> getUpcomingMovies({int page = 1});
  Future<MovieResponseModel> searchMovies(String query, {int page = 1});
  Future<List<GenreModel>> getGenres();
  Future<MovieResponseModel> getMoviesByGenre(int genreId, {int page = 1});
  Future<MovieDetailModel> getMovieDetails(int movieId);
  Future<VideoResponseModel> getMovieVideos(int movieId);
}

/// Implementation of MovieRemoteDataSource
class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient dioClient;
  static const String apiKey = 'ee37e806992023fd1c05fdbf775ea417'; // Replace with your actual API key

  MovieRemoteDataSourceImpl(this.dioClient);

  @override
  Future<MovieResponseModel> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await dioClient.get(
        '/movie/upcoming',
        queryParameters: {
          'api_key': apiKey,
          'page': page,
        },
      );

      if (response.data == null) {
        throw const NullException('Response data is null');
      }

      final jsonData = response.data as Map<String, dynamic>;
      return MovieResponseModel.fromJson(jsonData);
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ParsingException('Failed to parse upcoming movies: $e');
    }
  }

  @override
  Future<MovieResponseModel> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await dioClient.get(
        '/search/movie',
        queryParameters: {
          'api_key': apiKey,
          'query': query,
          'page': page,
        },
      );

      if (response.data == null) {
        throw const NullException('Response data is null');
      }

      final jsonData = response.data as Map<String, dynamic>;
      return MovieResponseModel.fromJson(jsonData);
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ParsingException('Failed to parse search results: $e');
    }
  }

  @override
  Future<List<GenreModel>> getGenres() async {
    try {
      final response = await dioClient.get(
        '/genre/movie/list',
        queryParameters: {
          'api_key': apiKey,
        },
      );

      if (response.data == null) {
        throw const NullException('Response data is null');
      }

      final jsonData = response.data as Map<String, dynamic>;
      final genreResponse = GenreResponseModel.fromJson(jsonData);
      return genreResponse.genres;
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ParsingException('Failed to parse genres: $e');
    }
  }

  @override
  Future<MovieResponseModel> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final response = await dioClient.get(
        '/discover/movie',
        queryParameters: {
          'api_key': apiKey,
          'with_genres': genreId,
          'page': page,
          'sort_by': 'popularity.desc',
        },
      );

      if (response.data == null) {
        throw const NullException('Response data is null');
      }

      final jsonData = response.data as Map<String, dynamic>;
      return MovieResponseModel.fromJson(jsonData);
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ParsingException('Failed to parse movies by genre: $e');
    }
  }

  @override
  Future<MovieDetailModel> getMovieDetails(int movieId) async {
    try {
      final response = await dioClient.get(
        '/movie/$movieId',
        queryParameters: {
          'api_key': apiKey,
        },
      );

      if (response.data == null) {
        throw const NullException('Response data is null');
      }

      final jsonData = response.data as Map<String, dynamic>;
      return MovieDetailModel.fromJson(jsonData);
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ParsingException('Failed to parse movie details: $e');
    }
  }

  @override
  Future<VideoResponseModel> getMovieVideos(int movieId) async {
    try {
      final response = await dioClient.get(
        '/movie/$movieId/videos',
        queryParameters: {
          'api_key': apiKey,
        },
      );

      if (response.data == null) {
        throw const NullException('Response data is null');
      }

      final jsonData = response.data as Map<String, dynamic>;
      return VideoResponseModel.fromJson(jsonData);
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ParsingException('Failed to parse movie videos: $e');
    }
  }
}
