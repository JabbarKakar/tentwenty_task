import '../../core/utils/result.dart';
import '../entities/movie_detail_entity.dart';
import '../repositories/movie_repository.dart';

/// Use case for getting movie details
class GetMovieDetailsUseCase {
  final MovieRepository repository;

  GetMovieDetailsUseCase(this.repository);

  /// Execute the use case
  Future<Result<MovieDetailEntity>> call(int movieId) async {
    return await repository.getMovieDetails(movieId);
  }
}
