import 'movie_entity.dart';

/// Pagination result entity
class PaginationEntity {
  final List<MovieEntity> movies;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const PaginationEntity({
    required this.movies,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });
}
