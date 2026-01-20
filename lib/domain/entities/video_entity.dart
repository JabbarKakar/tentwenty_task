/// Domain entity for Video
/// Data comes from TMDB "movie/#MOVIE_ID#/videos" API: id, key, name, site, type, size.
class VideoEntity {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final int? size;

  const VideoEntity({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    this.size,
  });

  /// Sites we can embed in-app (YouTube, Vimeo, Dailymotion).
  static const List<String> _playableSites = ['youtube', 'vimeo', 'dailymotion'];

  /// Whether we can play this video in-app (embed iframe).
  bool get isPlayable =>
      key.isNotEmpty &&
      _playableSites.contains(site.toLowerCase());

  /// Embed URL for WebView iframe (YouTube, Vimeo, Dailymotion). Volume on by default.
  /// YouTube: enablejsapi=1 for postMessage end detection.
  String get embedUrl {
    final s = site.toLowerCase();
    if (s == 'youtube') {
      return 'https://www.youtube.com/embed/$key?autoplay=1&playsinline=1&enablejsapi=1';
    }
    if (s == 'vimeo') {
      return 'https://player.vimeo.com/video/$key?autoplay=1';
    }
    if (s == 'dailymotion') {
      return 'https://www.dailymotion.com/embed/video/$key?autoplay=1';
    }
    return '';
  }

  /// External URL to open in app/browser (watch page).
  String get externalUrl {
    final s = site.toLowerCase();
    if (s == 'youtube') return 'https://www.youtube.com/watch?v=$key';
    if (s == 'vimeo') return 'https://vimeo.com/$key';
    if (s == 'dailymotion') return 'https://www.dailymotion.com/video/$key';
    return '';
  }

  /// Short label for "Open in X" (e.g. "YouTube", "Vimeo").
  String get externalLabel {
    final s = site.toLowerCase();
    if (s == 'youtube') return 'YouTube';
    if (s == 'vimeo') return 'Vimeo';
    if (s == 'dailymotion') return 'Dailymotion';
    return 'Browser';
  }

  /// Get YouTube video URL (kept for backward compatibility)
  String get youtubeUrl {
    if (site.toLowerCase() == 'youtube') {
      return 'https://www.youtube.com/watch?v=$key';
    }
    return '';
  }

  /// Check if it's a trailer
  bool get isTrailer => type.toLowerCase() == 'trailer';

  /// Check if it's from YouTube
  bool get isYouTube => site.toLowerCase() == 'youtube';
}
