import '../../core/utils/result.dart';
import '../entities/pagination_entity.dart';
import '../repositories/movie_repository.dart';

/// Use case for getting movies by genre
class GetMoviesByGenreUseCase {
  final MovieRepository repository;

  GetMoviesByGenreUseCase(this.repository);

  /// Execute the use case
  Future<Result<PaginationEntity>> call(int genreId, {int page = 1}) async {
    return await repository.getMoviesByGenre(genreId, page: page);
  }
}
