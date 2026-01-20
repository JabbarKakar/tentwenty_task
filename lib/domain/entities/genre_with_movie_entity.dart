import 'genre_entity.dart';
import 'movie_entity.dart';

/// Entity for genre with a representative movie image
class GenreWithMovieEntity {
  final GenreEntity genre;
  final String? backdropImageUrl;

  const GenreWithMovieEntity({
    required this.genre,
    this.backdropImageUrl,
  });
}
