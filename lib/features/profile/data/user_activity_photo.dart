// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:road_project_flutter/features/profile/data/media_item.dart';

class UserActivityAllPhoto {
  List<UserActivityPhoto> userActivityPhoto;
  UserActivityAllPhoto({required this.userActivityPhoto});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userActivityPhoto': userActivityPhoto.map((x) => x.toMap()).toList(),
    };
  }

  factory UserActivityAllPhoto.fromMap(Map<String, dynamic> map) {
    return UserActivityAllPhoto(
      userActivityPhoto: List<UserActivityPhoto>.from(
        (map['userActivityPhoto'] as List<int>).map<UserActivityPhoto>(
          (x) => UserActivityPhoto.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserActivityAllPhoto.fromJson(String source) =>
      UserActivityAllPhoto.fromMap(json.decode(source) as Map<String, dynamic>);
}

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'creator': creator,
      'caption': caption,
      'image': image,
      'type': type,
      'media': media,
      'createdAt': createdAt,
    };
  }

  factory UserActivityPhoto.fromMap(Map<String, dynamic> map) {
    return UserActivityPhoto(
      id: map['_id'] ?? "",
      creator: map['creator'] ?? "",
      caption: map['caption'] ?? "",
      image: map['image'] ?? "",
      type: map['type'] ?? "",
      duration: map['duration'] ?? 0,
      media: List<dynamic>.from((map['media'] ?? [])),
      createdAt: map['createdAt'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory UserActivityPhoto.fromJson(String source) =>
      UserActivityPhoto.fromMap(json.decode(source) as Map<String, dynamic>);
}
