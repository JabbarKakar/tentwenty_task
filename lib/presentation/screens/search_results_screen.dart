import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../domain/entities/movie_entity.dart';
import '../providers/search_provider.dart';
import '../widgets/loading_widget.dart';
import 'movie_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().searchMovies(widget.query);
    });
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
        title: Consumer<SearchProvider>(
          builder: (context, searchProvider, child) {
            return Text(
              '${searchProvider.searchResults.length} Results Found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            );
          },
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          if (searchProvider.isSearching) {
            return const LoadingWidget.fullScreen(
              color: Color(0xFF2E2739),
              message: 'Searching...',
            );
          }

          if (searchProvider.hasError) {
            return _buildErrorWidget(searchProvider);
          }

          if (searchProvider.searchResults.isEmpty) {
            return _buildEmptyWidget();
          }

          return _buildResultsList(searchProvider);
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildErrorWidget(SearchProvider searchProvider) {
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
              searchProvider.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                searchProvider.clearError();
                searchProvider.searchMovies(widget.query);
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
        'No results found',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF000000),
        ),
      ),
    );
  }

  Widget _buildResultsList(SearchProvider searchProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchProvider.searchResults.length,
      itemBuilder: (context, index) {
        final movie = searchProvider.searchResults[index];
        return _buildResultItem(movie, searchProvider);
      },
    );
  }

  Widget _buildResultItem(MovieEntity movie, SearchProvider searchProvider) {
    final genreName = searchProvider.getGenreNames(movie).split(',').first.trim();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movie: movie),
            ),
          );
        },
        child: Row(
          children: [
            // Movie Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: movie.posterImageUrl.isNotEmpty
                    ? Image.network(
                        movie.posterImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: LoadingWidget.small(
                              color: Color(0xFF2E2739),
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
            const SizedBox(width: 12),
            // Movie Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (genreName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      genreName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // More options icon
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF999999),
                size: 20,
              ),
              onPressed: () {
                // Show options menu
              },
            ),
          ],
        ),
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
}
