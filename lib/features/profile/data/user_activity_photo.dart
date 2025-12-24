class UserActivityPhoto {
  final String id;
  final String creator;
  final String caption;
  final List<String> image;
  final String type;
  final List<String> media;
  final String createdAt;

  UserActivityPhoto({
    required this.id,
    required this.creator,
    required this.caption,
    required this.image,
    required this.media,
    required this.type,
    required this.createdAt,
  });

  factory UserActivityPhoto.fromJson(Map<String, dynamic> json) =>
      UserActivityPhoto(
        id: json['_id'] ?? "",
        creator: json['creator'] ?? "",
        caption: json['caption'] ?? "",
        image: json['image'] != null
            ? (json['image'] as List).map((e) => e.toString()).toList()
            : [],
        media: json['media'] != null
            ? (json['media'] as List).map((e) => e.toString()).toList()
            : [],
        type: json['type'] ?? "",
        createdAt: json['createAt'] ?? "",
      );
}
