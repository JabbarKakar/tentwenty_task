import '../../core/utils/result.dart';
import '../entities/pagination_entity.dart';
import '../repositories/movie_repository.dart';

/// Use case for getting upcoming movies
class GetUpcomingMoviesUseCase {
  final MovieRepository repository;

  GetUpcomingMoviesUseCase(this.repository);

  /// Execute the use case
  Future<Result<PaginationEntity>> call({int page = 1}) async {
    return await repository.getUpcomingMovies(page: page);
  }
}
