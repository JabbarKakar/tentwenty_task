import '../../domain/entities/video_entity.dart';

/// Data model for Video
class VideoModel implements VideoEntity {
  @override
  final String id;
  @override
  final String key;
  @override
  final String name;
  @override
  final String site;
  @override
  final String type;
  @override
  final int? size;

  const VideoModel({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    this.size,
  });

  static const List<String> _playableSites = ['youtube', 'vimeo', 'dailymotion'];

  @override
  bool get isPlayable =>
      key.isNotEmpty && _playableSites.contains(site.toLowerCase());

  @override
  String get embedUrl {
    final s = site.toLowerCase();
    if (s == 'youtube') return 'https://www.youtube.com/embed/$key?autoplay=1&playsinline=1&enablejsapi=1';
    if (s == 'vimeo') return 'https://player.vimeo.com/video/$key?autoplay=1';
    if (s == 'dailymotion') return 'https://www.dailymotion.com/embed/video/$key?autoplay=1';
    return '';
  }

  @override
  String get externalUrl {
    final s = site.toLowerCase();
    if (s == 'youtube') return 'https://www.youtube.com/watch?v=$key';
    if (s == 'vimeo') return 'https://vimeo.com/$key';
    if (s == 'dailymotion') return 'https://www.dailymotion.com/video/$key';
    return '';
  }

  @override
  String get externalLabel {
    final s = site.toLowerCase();
    if (s == 'youtube') return 'YouTube';
    if (s == 'vimeo') return 'Vimeo';
    if (s == 'dailymotion') return 'Dailymotion';
    return 'Browser';
  }

  @override
  String get youtubeUrl {
    if (site.toLowerCase() == 'youtube') {
      return 'https://www.youtube.com/watch?v=$key';
    }
    return '';
  }

  @override
  bool get isTrailer => type.toLowerCase() == 'trailer';

  @override
  bool get isYouTube => site.toLowerCase() == 'youtube';

  /// Create VideoModel from JSON
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    try {
      return VideoModel(
        id: json['id'] as String? ?? '',
        key: json['key'] as String? ?? '',
        name: json['name'] as String? ?? '',
        site: json['site'] as String? ?? '',
        type: json['type'] as String? ?? '',
        size: json['size'] as int?,
      );
    } catch (e) {
      throw Exception('Failed to parse VideoModel: $e');
    }
  }
}

/// Data model for Video Response
class VideoResponseModel {
  final List<VideoModel> results;

  const VideoResponseModel({
    required this.results,
  });

  /// Create VideoResponseModel from JSON
  factory VideoResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final resultsList = json['results'] as List<dynamic>? ?? [];
      return VideoResponseModel(
        results: resultsList
            .map((item) => VideoModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to parse VideoResponseModel: $e');
    }
  }
}
