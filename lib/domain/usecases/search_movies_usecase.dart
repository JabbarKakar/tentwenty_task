import '../../core/utils/result.dart';
import '../entities/pagination_entity.dart';
import '../repositories/movie_repository.dart';

/// Use case for searching movies
class SearchMoviesUseCase {
  final MovieRepository repository;

  SearchMoviesUseCase(this.repository);

  /// Execute the use case
  Future<Result<PaginationEntity>> call(String query, {int page = 1}) async {
    return await repository.searchMovies(query, page: page);
  }
}
