import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/genre_entity.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/pagination_entity.dart';
import '../providers/search_provider.dart';
import '../widgets/loading_widget.dart';
import 'movie_detail_screen.dart';

class GenreMoviesScreen extends StatefulWidget {
  final GenreEntity genre;

  const GenreMoviesScreen({
    super.key,
    required this.genre,
  });

  @override
  State<GenreMoviesScreen> createState() => _GenreMoviesScreenState();
}

class _GenreMoviesScreenState extends State<GenreMoviesScreen> {
  final ScrollController _scrollController = ScrollController();
  List<MovieEntity> _movies = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (_hasMore && !_isLoadingMore) {
        _loadMoreMovies();
      }
    }
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final searchProvider = context.read<SearchProvider>();
      final result = await searchProvider.getMoviesByGenre(
        widget.genre.id,
        page: 1,
      );

      result.when(
        success: (pagination) {
          setState(() {
            _movies = pagination.movies;
            _currentPage = pagination.currentPage;
            _hasMore = pagination.hasMore;
            _isLoading = false;
            _error = null;
          });
        },
        error: (failure) {
          setState(() {
            _isLoading = false;
            _error = failure.message;
            _movies = [];
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
        _movies = [];
      });
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final searchProvider = context.read<SearchProvider>();
      final result = await searchProvider.getMoviesByGenre(
        widget.genre.id,
        page: _currentPage + 1,
      );

      result.when(
        success: (pagination) {
          setState(() {
            _movies.addAll(pagination.movies);
            _currentPage = pagination.currentPage;
            _hasMore = pagination.hasMore;
            _isLoadingMore = false;
          });
        },
        error: (failure) {
          setState(() {
            _isLoadingMore = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000000)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.genre.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget.fullScreen(
              color: Color(0xFF2E2739),
              message: 'Loading movies...',
            )
          : _error != null
              ? _buildErrorWidget()
              : _movies.isEmpty
                  ? _buildEmptyWidget()
                  : _buildMoviesList(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadMovies,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E2739),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Text(
        'No movies found in this category',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF000000),
        ),
      ),
    );
  }

  Widget _buildMoviesList() {
    return RefreshIndicator(
      onRefresh: _loadMovies,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Featured movie card (first movie)
            if (_movies.isNotEmpty) ...[
              _buildFeaturedCard(_movies[0]),
              const SizedBox(height: 16),
            ],
            // Other movie cards
            ..._movies.skip(1).map((movie) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildNormalCard(movie),
                )),
            // Loading more indicator
            if (_isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: LoadingWidget.medium(
                    color: Color(0xFF2E2739),
                  ),
                ),
              ),
            if (!_hasMore && _movies.length >= 6)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No more movies to load',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(MovieEntity movie) {
    return GestureDetector(
      onTap: () => _navigateToBooking(movie),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: movie.backdropImageUrl.isNotEmpty
                  ? Image.network(
                      movie.backdropImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: LoadingWidget.small(
                              color: Color(0xFF2E2739),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie),
                    ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                movie.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalCard(MovieEntity movie) {
    return GestureDetector(
      onTap: () => _navigateToBooking(movie),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: movie.backdropImageUrl.isNotEmpty
                  ? Image.network(
                      movie.backdropImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: LoadingWidget.small(
                              color: Color(0xFF2E2739),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie),
                    ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                movie.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF2E2739),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, 'Dashboard', false),
          _buildNavItem(Icons.play_circle_outline, 'Watch', true),
          _buildNavItem(Icons.video_library, 'Media Library', false),
          _buildNavItem(Icons.more_horiz, 'More', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: isActive ? Colors.white : Colors.grey[600],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _navigateToBooking(MovieEntity movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movie: movie),
      ),
    );
  }
}
