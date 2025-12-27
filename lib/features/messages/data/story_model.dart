class Story {
  final String id;
  final String name;
  final String avatar;
  final bool isYourStory;

  Story({
    required this.id,
    required this.name,
    required this.avatar,
    this.isYourStory = false,
  });

  factory Story.fromApiJson(Map<String, dynamic> json) {
    return Story(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: _normalizeAvatarUrl(json['image']?.toString() ?? ''),
      isYourStory: false,
    );
  }

  static String _normalizeAvatarUrl(String value) {
    final v = value.trim();
    if (v.isEmpty) return '';

    // Fix malformed URLs like: http://10.10.7.11:5500https://...
    final secondHttpIndex = v.indexOf('http', 1);
    if (secondHttpIndex != -1) {
      return v.substring(secondHttpIndex);
    }

    if (v.startsWith('http://') || v.startsWith('https://')) {
      return v;
    }

    return v;
  }
}