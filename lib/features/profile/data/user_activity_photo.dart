import 'package:road_project_flutter/features/profile/data/media_item.dart';

class UserActivityPhoto {
  final String id;
  final String creator;
  final String caption;
  final String image;
  final MediaType type;
  final List<dynamic> media;
  final num duration;
  final String createdAt;

  UserActivityPhoto({
    required this.id,
    required this.creator,
    required this.caption,
    required this.image,
    required this.media,
    required this.type,
    required this.duration,
    required this.createdAt,
  });

  factory UserActivityPhoto.fromJson(Map<String, dynamic> json) =>
      UserActivityPhoto(
        id: json['_id'] ?? "",
        creator: json['creator'] ?? "",
        caption: json['caption'] ?? "",
        image: json['image'] ?? "",
        media: json['media'] ?? "",
        type: json['type'] ?? "",
        duration: json['duration'] ?? "",
        createdAt: json['createAt'] ?? "",
      );
}
