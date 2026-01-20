/// Domain entity for Movie
class MovieEntity {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final String? releaseDate;
  final List<int>? genreIds;

  const MovieEntity({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.genreIds,
  });

  /// Get full image URL for backdrop
  String get backdropImageUrl {
    if (backdropPath != null) {
      return 'https://image.tmdb.org/t/p/w500$backdropPath';
    } else if (posterPath != null) {
      return 'https://image.tmdb.org/t/p/w500$posterPath';
    }
    return '';
  }

  /// Get full image URL for poster
  String get posterImageUrl {
    if (posterPath != null) {
      return 'https://image.tmdb.org/t/p/w500$posterPath';
    }
    return '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
