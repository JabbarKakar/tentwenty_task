import '../../core/utils/result.dart';
import '../entities/genre_entity.dart';
import '../repositories/movie_repository.dart';

/// Use case for getting movie genres
class GetGenresUseCase {
  final MovieRepository repository;

  GetGenresUseCase(this.repository);

  /// Execute the use case
  Future<Result<List<GenreEntity>>> call() async {
    return await repository.getGenres();
  }
}
