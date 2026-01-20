/// Domain entity for Movie Detail
class MovieDetailEntity {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final String? releaseDate;
  final List<String> genres;
  final int? runtime;
  final double? voteAverage;
  final int? voteCount;
  final String? status;

  const MovieDetailEntity({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    this.releaseDate,
    required this.genres,
    this.runtime,
    this.voteAverage,
    this.voteCount,
    this.status,
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

  /// Format release date
  String? get formattedReleaseDate {
    if (releaseDate == null) return null;
    try {
      final date = DateTime.parse(releaseDate!);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return 'In Theaters ${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return releaseDate;
    }
  }
}
