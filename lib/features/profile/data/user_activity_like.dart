import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserActivityAllLike {
  List<UserActivityLike> userActivityLike;
  UserActivityAllLike({required this.userActivityLike});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userActivityLike': userActivityLike.map((x) => x.toMap()).toList(),
    };
  }

  factory UserActivityAllLike.fromMap(Map<String, dynamic> map) {
    return UserActivityAllLike(
      userActivityLike: List<UserActivityLike>.from(
        (map['userActivityLike'] as List<int>).map<UserActivityLike>(
          (x) => UserActivityLike.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserActivityAllLike.fromJson(String source) =>
      UserActivityAllLike.fromMap(json.decode(source) as Map<String, dynamic>);
}

class UserActivityLike {
  final String id;
  final String user;
  final String createAt;
  UserActivityLike({
    required this.id,
    required this.user,
    required this.createAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'user': user, 'createAt': createAt};
  }

  factory UserActivityLike.fromMap(Map<String, dynamic> map) {
    return UserActivityLike(
      id: map['_id'] as String,
      user: map['user'] as String,
      createAt: map['createAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserActivityLike.fromJson(String source) =>
      UserActivityLike.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Post {
  final String id;
  final String creator;
  final String caption;
  final String type;
  final List<String> image;
  final List<String> media;
  final String createAt;
  Post({
    required this.id,
    required this.creator,
    required this.caption,
    required this.type,
    required this.image,
    required this.media,
    required this.createAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'creator': creator,
      'caption': caption,
      'type': type,
      'image': image,
      'media': media,
      'createAt': createAt,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['_id'] as String,
      creator: map['creator'] as String,
      caption: map['caption'] as String,
      type: map['type'] as String,
      image: List<String>.from((map['image'] as List<String>)),
      media: List<String>.from((map['media'] as List<String>)),
      createAt: map['createAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) =>
      Post.fromMap(json.decode(source) as Map<String, dynamic>);
}
