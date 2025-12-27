class ChatMessage {
  final String id;
  final String participantId;
  final String name;
  final String message;
  final String time;
  final String avatar;
  final bool isOnline;

  ChatMessage({
    required this.id,
    required this.participantId,
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    required this.isOnline,
  });

  factory ChatMessage.fromConversationJson(
    Map<String, dynamic> json, {
    required String timeLabel,
  }) {
    final participant = (json['participant'] is Map)
        ? Map<String, dynamic>.from(json['participant'] as Map)
        : <String, dynamic>{};
    final lastMessage = (json['lastMessage'] is Map)
        ? Map<String, dynamic>.from(json['lastMessage'] as Map)
        : <String, dynamic>{};

    final rawAvatar = participant['image']?.toString() ?? '';
    final normalizedAvatar = _normalizeAvatarUrl(rawAvatar);

    return ChatMessage(
      id: json['_id']?.toString() ?? '',
      participantId: participant['_id']?.toString() ?? '',
      name: participant['name']?.toString() ?? '',
      message: lastMessage['text']?.toString() ?? '',
      time: timeLabel,
      avatar: normalizedAvatar,
      isOnline: false,
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

    // Absolute URL
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return v;
    }

    // Relative path - caller should prefix with base imageUrl when needed.
    return v;
  }
}
