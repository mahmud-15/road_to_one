class UserActivityLike {
  final String id;
  final Post? post;
  final String user;
  final String createAt;
  UserActivityLike({
    required this.id,
    required this.user,
    required this.post,
    required this.createAt,
  });

  factory UserActivityLike.fromJson(Map<String, dynamic> json) =>
      UserActivityLike(
        id: json['_id'] ?? "",
        user: json['user'] ?? "",
        post: Post.formJson(json['post'] ?? {}),
        createAt: json['createAt'] ?? "",
      );
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

  factory Post.formJson(Map<String, dynamic> json) => Post(
    id: json['_id'] ?? "",
    creator: json['creator'] ?? "",
    caption: json['caption'] ?? "",
    type: json['type'] ?? "",
    image: (json['image'] as List).map((e) => e.toString()).toList(),
    media: (json['media'] as List).map((e) => e.toString()).toList(),
    createAt: json['createAt'] ?? "",
  );
}
