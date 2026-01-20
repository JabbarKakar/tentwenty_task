import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/movie_detail_entity.dart';
import '../providers/movie_detail_provider.dart';
import '../widgets/loading_widget.dart';
import 'hall_and_times_screen.dart';
import 'video_player_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieEntity movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MovieDetailProvider>();
      provider.loadMovieDetails(widget.movie.id);
      provider.loadMovieVideos(widget.movie.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      body: Consumer<MovieDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget.fullScreen(
              color: Color(0xFF2E2739),
              message: 'Loading movie details...',
            );
          }

          if (provider.hasError && provider.movieDetail == null) {
            return _buildErrorWidget(provider);
          }

          final movieDetail = provider.movieDetail;
          if (movieDetail == null) {
            return _buildErrorWidget(provider);
          }

          return CustomScrollView(
            slivers: [
              // Top section with poster
              _buildTopSection(movieDetail, provider),
              // Bottom section with details
              SliverToBoxAdapter(
                child: _buildBottomSection(movieDetail, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(MovieDetailProvider provider) {
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
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.loadMovieDetails(widget.movie.id);
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

  Widget _buildTopSection(movieDetail, MovieDetailProvider provider) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Watch',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Movie backdrop image
            movieDetail.backdropImageUrl.isNotEmpty
                ? Image.network(
                    movieDetail.backdropImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.movie, color: Colors.white70),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: LoadingWidget.medium(color: Colors.white70),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.movie, color: Colors.white70),
                  ),
            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Movie title and release date
            Positioned(
              left: 16,
              right: 16,
              top: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movieDetail.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700), // Gold color
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (movieDetail.formattedReleaseDate != null)
                    Text(
                      movieDetail.formattedReleaseDate!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Action buttons
            Positioned(
              left: 16,
              right: 16,
              bottom: 80,
              child: Column(
                children: [
                  // Get Tickets button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HallAndTimesScreen(movieTitle: movieDetail.title),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF61C3F2), // Light blue
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Get Tickets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Watch Trailer button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.trailer != null
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    video: provider.trailer!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text(
                        'Watch Trailer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF564CA3), // Dark gray/purple
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(movieDetail, MovieDetailProvider provider) {
    return Container(
      color: const Color(0xFFF6F6FA),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genres section
          if (movieDetail.genres.isNotEmpty) ...[
            const Text(
              'Genres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: movieDetail.genres.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final genre = entry.value;
                final colors = [
                  const Color(0xFF15D2BC), // Light green
                  const Color(0xFFE26CA5), // Pink
                  const Color(0xFF564CA3), // Purple
                  const Color(0xFFCD9D0F), // Orange
                ];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    genre,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          // Overview section
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            movieDetail.overview,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
