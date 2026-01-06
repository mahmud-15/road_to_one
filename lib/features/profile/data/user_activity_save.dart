// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserActivitySave {
  final String id;
  final Post post;
  final String user;
  final DateTime createAt;
  UserActivitySave({
    required this.id,
    required this.post,
    required this.user,
    required this.createAt,
  });

  factory UserActivitySave.fromJson(Map<String, dynamic> json) =>
      UserActivitySave(
        id: json['_id'] ?? "",
        post: Post.fromJson(json['post']),
        user: json['user'] ?? "",

        createAt: DateTime.parse(json['createdAt'].toString()),
      );
}

class Post {
  final List<String> media;
  final String id;
  final String type;
  final String creator;
  final String caption;
  final List<String> image;
  final DateTime createAt;
  Post({
    required this.media,
    required this.id,
    required this.creator,
    required this.caption,
    required this.image,
    required this.createAt,
    required this.type,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    media: json['media'] != null
        ? (json['media'] as List).map((e) => e.toString()).toList()
        : [],
    id: json['_id'] ?? "",
    creator: json['creator'] ?? "",
    type: json['type'] ?? "",
    caption: json['caption'] ?? "",
    image: json['image'] != null
        ? (json['image'] as List).map((e) => e.toString()).toList()
        : [],
    createAt: DateTime.parse(json['createdAt'].toString()),
  );
}
