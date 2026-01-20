import '../../domain/entities/genre_entity.dart';

/// Data model for Genre
class GenreModel extends GenreEntity {
  const GenreModel({
    required super.id,
    required super.name,
  });

  /// Create GenreModel from JSON
  factory GenreModel.fromJson(Map<String, dynamic> json) {
    try {
      return GenreModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
      );
    } catch (e) {
      throw Exception('Failed to parse GenreModel: $e');
    }
  }

  /// Convert GenreModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Convert GenreModel to GenreEntity
  GenreEntity toEntity() {
    return GenreEntity(
      id: id,
      name: name,
    );
  }
}

/// Data model for Genre Response
class GenreResponseModel {
  final List<GenreModel> genres;

  const GenreResponseModel({
    required this.genres,
  });

  /// Create GenreResponseModel from JSON
  factory GenreResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final genresList = json['genres'] as List<dynamic>? ?? [];
      return GenreResponseModel(
        genres: genresList
            .map((item) => GenreModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to parse GenreResponseModel: $e');
    }
  }
}
