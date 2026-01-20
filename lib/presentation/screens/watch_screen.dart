import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../domain/entities/movie_entity.dart';
import '../providers/movie_provider.dart';
import '../widgets/loading_widget.dart';
import 'movie_detail_screen.dart';
import 'search_screen.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load movies when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadUpcomingMovies();
    });
    // Add scroll listener for pagination
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
      // Load more when user scrolls to 80% of the list
      final movieProvider = context.read<MovieProvider>();
      if (movieProvider.hasMore && !movieProvider.isLoadingMore) {
        movieProvider.loadMoreMovies();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Content Area
            Expanded(
              child: Consumer<MovieProvider>(
                builder: (context, movieProvider, child) {
                  if (movieProvider.isLoading) {
                    return const LoadingWidget.fullScreen(
                      color: Color(0xFF2E2739),
                      message: 'Loading movies...',
                    );
                  }

                  if (movieProvider.hasError) {
                    return _buildErrorWidget(movieProvider);
                  }

                  if (movieProvider.movies.isEmpty) {
                    return _buildEmptyWidget();
                  }

                  return _buildContent(movieProvider.movies);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Watch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              size: 24,
              color: Color(0xFF000000),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(MovieProvider movieProvider) {
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
              'Error',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movieProvider.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                movieProvider.clearError();
                movieProvider.loadUpcomingMovies();
              },
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
        'No movies available',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF000000),
        ),
      ),
    );
  }

  Widget _buildContent(List<MovieEntity> movies) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<MovieProvider>().refreshMovies();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Featured movie card (first movie)
            if (movies.isNotEmpty) ...[
              _buildFeaturedCard(movies[0]),
              const SizedBox(height: 16),
            ],
            // Other movie cards
            ...movies.skip(1).map((movie) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildNormalCard(movie),
                )),
            // Loading more indicator
            Consumer<MovieProvider>(
              builder: (context, movieProvider, child) {
                if (movieProvider.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: LoadingWidget.medium(
                        color: Color(0xFF2E2739),
                      ),
                    ),
                  );
                }
                if (!movieProvider.hasMore && movies.length >= 6) {
                  return const Padding(
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
                  );
                }
                return const SizedBox.shrink();
              },
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
          _buildNavItem(AppAssets.iconsDashboard, 'Dashboard', false),
          _buildNavItem(AppAssets.iconsWatch, 'Watch', true),
          _buildNavItem(AppAssets.iconsMediaLibrary, 'Media Library', false),
          _buildNavItem(AppAssets.iconsMore, 'More', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(String iconPath, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppAssets.navIcon(iconPath, isActive: isActive),
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
