import '../../domain/entities/movie_entity.dart';

/// Data model for Movie (matches API response)
class MovieModel extends MovieEntity {
  const MovieModel({
    required super.id,
    required super.title,
    super.posterPath,
    super.backdropPath,
    super.overview,
    super.releaseDate,
    super.genreIds,
  });

  /// Create MovieModel from JSON
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    try {
      final genreIdsList = json['genre_ids'] as List<dynamic>?;
      return MovieModel(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        posterPath: json['poster_path'] as String?,
        backdropPath: json['backdrop_path'] as String?,
        overview: json['overview'] as String?,
        releaseDate: json['release_date'] as String?,
        genreIds: genreIdsList?.map((e) => e as int).toList(),
      );
    } catch (e) {
      throw Exception('Failed to parse MovieModel: $e');
    }
  }

  /// Convert MovieModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'overview': overview,
      'release_date': releaseDate,
    };
  }

  /// Convert MovieModel to MovieEntity
  MovieEntity toEntity() {
    return MovieEntity(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      releaseDate: releaseDate,
      genreIds: genreIds,
    );
  }
}

/// Data model for Movie Response
class MovieResponseModel {
  final List<MovieModel> results;
  final int page;
  final int totalPages;
  final int totalResults;

  const MovieResponseModel({
    required this.results,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  /// Create MovieResponseModel from JSON
  factory MovieResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final resultsList = json['results'] as List<dynamic>? ?? [];
      return MovieResponseModel(
        results: resultsList
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        page: json['page'] as int? ?? 0,
        totalPages: json['total_pages'] as int? ?? 0,
        totalResults: json['total_results'] as int? ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to parse MovieResponseModel: $e');
    }
  }

  /// Convert MovieResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'results': results.map((movie) => movie.toJson()).toList(),
      'page': page,
      'total_pages': totalPages,
      'total_results': totalResults,
    };
  }
}
