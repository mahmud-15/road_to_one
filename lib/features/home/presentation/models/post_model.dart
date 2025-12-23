class PostModel {
  final String id;
  final Creator creator;
  final String caption;
  final String type;
  final String createAt;
  final int commentOfPost;
  final int likeOfPost;
  final bool isOwner;
  final bool hasSave;
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
    id: json['_id']?.toString() ?? "",
    creator: Creator.fromJson((json['creator'] as Map?)?.cast<String, dynamic>() ?? const {}),
    caption: json['caption']?.toString() ?? "",
    type: json['type']?.toString() ?? "",
    createAt: (json['createdAt'] ?? json['createAt'] ?? json['updatedAt'])?.toString() ?? "",
    commentOfPost: json['commentOfPost'] ?? 0,
    likeOfPost: json['likeOfPost'] ?? 0,
    isOwner: json['isOwner'] ?? false,
    hasSave: json['hasSave'] ?? false,
    isLiked: json['isLiked'] ?? false,
    connectionStatus: json['connectionStatus']?.toString() ?? "",
    image: (json['image'] as List?)?.map((e) => e?.toString() ?? "").where((e) => e.isNotEmpty).toList() ?? const <String>[],
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
    id: (json['_id'] ?? json['id'])?.toString() ?? "",
    name: json['name']?.toString() ?? "",
    image: json['image']?.toString() ?? "",
    profileMode: (json['profile_mode'] ?? json['profileMode'])?.toString() ?? "",
  );
}
