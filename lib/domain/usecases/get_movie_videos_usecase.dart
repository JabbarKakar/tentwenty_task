import '../../core/utils/result.dart';
import '../entities/video_entity.dart';
import '../repositories/movie_repository.dart';

/// Use case for getting movie videos
class GetMovieVideosUseCase {
  final MovieRepository repository;

  GetMovieVideosUseCase(this.repository);

  /// Execute the use case
  Future<Result<List<VideoEntity>>> call(int movieId) async {
    return await repository.getMovieVideos(movieId);
  }
}
