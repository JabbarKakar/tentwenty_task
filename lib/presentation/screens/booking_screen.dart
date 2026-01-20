import 'package:flutter/material.dart';
import '../../domain/entities/movie_entity.dart';
import '../widgets/loading_widget.dart';

class BookingScreen extends StatelessWidget {
  final MovieEntity movie;

  const BookingScreen({
    super.key,
    required this.movie,
  });

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
          movie.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 400,
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
                              child: LoadingWidget.medium(
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
            const SizedBox(height: 24),
            // Movie Details
            if (movie.overview != null && movie.overview!.isNotEmpty) ...[
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                movie.overview!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty) ...[
              Text(
                'Release Date: ${movie.releaseDate}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Booking Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implement booking logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking functionality to be implemented'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E2739),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Book Tickets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
