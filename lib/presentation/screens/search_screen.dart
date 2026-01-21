import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/genre_entity.dart';
import '../../domain/entities/movie_entity.dart';
import '../providers/search_provider.dart';
import '../widgets/loading_widget.dart';
import 'genre_movies_screen.dart';
import 'movie_detail_screen.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().loadGenres();
    });
  }

  void _onSearchTextChanged() {
    setState(() {}); // Rebuild to update suffix icon visibility
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (value.trim().isNotEmpty) {
      context.read<SearchProvider>().searchMovies(value);
    } else {
      context.read<SearchProvider>().clearSearch();
    }
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(query: value),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),
            // Content Area
            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, searchProvider, child) {
                  if (searchProvider.isLoadingGenres) {
                    return const LoadingWidget.fullScreen(
                      color: AppColors.primaryDark,
                      message: 'Loading categories...',
                    );
                  }

                  if (searchProvider.hasError && searchProvider.genres.isEmpty) {
                    return _buildErrorWidget(searchProvider);
                  }

                  // Show search results if query exists, otherwise show categories
                  if (_searchController.text.trim().isNotEmpty) {
                    return _buildSearchResults(searchProvider);
                  }

                  return _buildCategoriesGrid(searchProvider);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
                decoration: InputDecoration(
                  hintText: 'TV shows, movies and more',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<SearchProvider>().clearSearch();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
                searchProvider.loadGenres();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
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

  Widget _buildCategoriesGrid(SearchProvider searchProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: searchProvider.genres.length,
        itemBuilder: (context, index) {
          final genre = searchProvider.genres[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GenreMoviesScreen(genre: genre),
                ),
              );
            },
            child: _buildCategoryCard(genre),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(GenreEntity genre) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final imageUrl = searchProvider.getGenreImageUrl(genre.id);
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Movie backdrop image or placeholder
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderBackground();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildPlaceholderBackground();
                    },
                  )
                else
                  _buildPlaceholderBackground(),
                // Genre label overlay
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
                      genre.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.borderLight,
            AppColors.textMuted,
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider searchProvider) {
    if (searchProvider.isSearching) {
      return const Center(
        child: LoadingWidget.medium(
          color: AppColors.primaryDark,
        ),
      );
    }

    if (searchProvider.searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primaryDark,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            'Top Results',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: searchProvider.searchResults.length,
            itemBuilder: (context, index) {
              final movie = searchProvider.searchResults[index];
              return _buildSearchResultItem(movie, searchProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultItem(MovieEntity movie, SearchProvider searchProvider) {
    final genreName = searchProvider.getGenreNames(movie).split(',').first.trim();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _navigateToMovieDetail(movie),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            // Movie Poster
            ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: movie.posterImageUrl.isNotEmpty
                  ? Image.network(
                      movie.posterImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.borderLight,
                          child: const Icon(Icons.movie),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: LoadingWidget.small(
                            color: AppColors.primaryDark,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.borderLight,
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
                    color: AppColors.primaryDark,
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
                      color: AppColors.textMuted,
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
                color: AppColors.textMuted,
              size: 20,
            ),
            onPressed: () => _navigateToMovieDetail(movie),
          ),
        ],
        ),
      ),
    );
  }

  void _navigateToMovieDetail(MovieEntity movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
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
            color: isActive ? Colors.white : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
