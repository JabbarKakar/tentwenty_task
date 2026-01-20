import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/movie_remote_datasource.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/usecases/get_genres_usecase.dart';
import '../../domain/usecases/get_movie_details_usecase.dart';
import '../../domain/usecases/get_movie_videos_usecase.dart';
import '../../domain/usecases/get_movies_by_genre_usecase.dart';
import '../../domain/usecases/get_upcoming_movies_usecase.dart';
import '../../domain/usecases/search_movies_usecase.dart';
import '../../presentation/providers/movie_detail_provider.dart';
import '../../presentation/providers/movie_provider.dart';
import '../../presentation/providers/search_provider.dart';
import '../network/dio_client.dart';

/// Dependency Injection Container
class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Core
  late final DioClient _dioClient = DioClient();

  // Data Sources
  late final MovieRemoteDataSource _movieRemoteDataSource =
      MovieRemoteDataSourceImpl(_dioClient);

  // Repositories
  late final MovieRepository _movieRepository =
      MovieRepositoryImpl(_movieRemoteDataSource);

  // Use Cases
  late final GetUpcomingMoviesUseCase _getUpcomingMoviesUseCase =
      GetUpcomingMoviesUseCase(_movieRepository);
  late final SearchMoviesUseCase _searchMoviesUseCase =
      SearchMoviesUseCase(_movieRepository);
  late final GetGenresUseCase _getGenresUseCase =
      GetGenresUseCase(_movieRepository);
  late final GetMoviesByGenreUseCase _getMoviesByGenreUseCase =
      GetMoviesByGenreUseCase(_movieRepository);
  late final GetMovieDetailsUseCase _getMovieDetailsUseCase =
      GetMovieDetailsUseCase(_movieRepository);
  late final GetMovieVideosUseCase _getMovieVideosUseCase =
      GetMovieVideosUseCase(_movieRepository);

  /// Initialize providers
  List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<MovieProvider>(
        create: (_) => MovieProvider(_getUpcomingMoviesUseCase),
      ),
      ChangeNotifierProvider<SearchProvider>(
        create: (_) => SearchProvider(
          searchMoviesUseCase: _searchMoviesUseCase,
          getGenresUseCase: _getGenresUseCase,
          getMoviesByGenreUseCase: _getMoviesByGenreUseCase,
        ),
      ),
      ChangeNotifierProvider<MovieDetailProvider>(
        create: (_) => MovieDetailProvider(
          getMovieDetailsUseCase: _getMovieDetailsUseCase,
          getMovieVideosUseCase: _getMovieVideosUseCase,
        ),
      ),
    ];
  }
}
