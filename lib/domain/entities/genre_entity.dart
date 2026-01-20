/// Domain entity for Genre
class GenreEntity {
  final int id;
  final String name;

  const GenreEntity({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GenreEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
