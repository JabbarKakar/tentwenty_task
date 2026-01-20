import '../../domain/entities/movie_detail_entity.dart';

/// Data model for Movie Detail (matches API response)
class MovieDetailModel extends MovieDetailEntity {
  const MovieDetailModel({
    required super.id,
    required super.title,
    super.posterPath,
    super.backdropPath,
    required super.overview,
    super.releaseDate,
    required super.genres,
    super.runtime,
    super.voteAverage,
    super.voteCount,
    super.status,
  });

  /// Create MovieDetailModel from JSON
  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    try {
      final genresList = json['genres'] as List<dynamic>? ?? [];
      return MovieDetailModel(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        posterPath: json['poster_path'] as String?,
        backdropPath: json['backdrop_path'] as String?,
        overview: json['overview'] as String? ?? '',
        releaseDate: json['release_date'] as String?,
        genres: genresList
            .map((g) => (g as Map<String, dynamic>)['name'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toList(),
        runtime: json['runtime'] as int?,
        voteAverage: (json['vote_average'] as num?)?.toDouble(),
        voteCount: json['vote_count'] as int?,
        status: json['status'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to parse MovieDetailModel: $e');
    }
  }

  /// Convert MovieDetailModel to MovieDetailEntity
  MovieDetailEntity toEntity() {
    return MovieDetailEntity(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      releaseDate: releaseDate,
      genres: genres,
      runtime: runtime,
      voteAverage: voteAverage,
      voteCount: voteCount,
      status: status,
    );
  }
}
