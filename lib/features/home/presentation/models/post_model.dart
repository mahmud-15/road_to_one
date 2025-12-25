class PostModel {
  final String id;
  final Creator creator;
  final String caption;
  final String type;
  final DateTime createAt;
  final int commentOfPost;
  int likeOfPost;
  final bool isOwner;
  bool hasSave;
  bool isLiked;
  final String connectionStatus;
  final List<String> image;
  PostModel({
    required this.id,
    required this.creator,
    required this.caption,
    required this.type,
    required this.createAt,
    required this.commentOfPost,
    required this.likeOfPost,
    required this.isOwner,
    required this.hasSave,
    required this.isLiked,
    required this.connectionStatus,
    required this.image,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    id: json['_id'] ?? "",
    creator: Creator.fromJson(json['creator']),
    caption: json['caption'] ?? "",
    type: json['type'] ?? "",
    createAt: DateTime.parse(json['createdAt']),
    commentOfPost: json['commentOfPost'] ?? 0,
    likeOfPost: json['likeOfPost'] ?? 0,
    isOwner: json['isOwner'] ?? false,
    hasSave: json['hasSave'] ?? false,
    isLiked: json['isLiked'] ?? false,
    connectionStatus: json['connectionStatus'] ?? "",
    image: json['image'] != null
        ? (json['image'] as List).map((e) => e.toString()).toList()
        : [],
  );
}

class Creator {
  final String id;
  final String name;
  final String image;
  final String profileMode;
  Creator({
    required this.id,
    required this.name,
    required this.image,
    required this.profileMode,
  });

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
    id: json['id'] ?? "",
    name: json['name'] ?? "",
    image: json['image'] ?? "",
    profileMode: json['profileMode'] ?? "",
  );
}
