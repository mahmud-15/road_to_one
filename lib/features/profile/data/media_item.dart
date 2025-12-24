enum UserMediaType { image, video }

class MediaItem {
  final String url;
  final UserMediaType type;
  final String? duration;
  final String? thumbnail;

  MediaItem({
    required this.url,
    required this.type,
    this.duration,
    this.thumbnail,
  });
}
