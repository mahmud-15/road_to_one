class CommentModel {
  final String id;
  final Creator creator;
  final String text;
  final String image;
  final String createAt;
  bool isLiked;
  CommentModel({
    required this.id,
    required this.creator,
    required this.text,
    required this.image,
    required this.createAt,
    required this.isLiked,
  });
  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['_id'] ?? "",
    creator: Creator.fromJson(json['creator']),
    text: json['text'] ?? "",
    image: json['image'] ?? "",
    createAt: json['createdAt'] ?? (json['createAt'] ?? ""),
    isLiked: json['isLiked'] ?? false,
  );
}

class ReplyModel {
  final String id;
  final String commentId;
  final Creator creator;
  final String text;
  final String image;
  final String createdAt;
  final bool isCreator;

  ReplyModel({
    required this.id,
    required this.commentId,
    required this.creator,
    required this.text,
    required this.image,
    required this.createdAt,
    required this.isCreator,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) => ReplyModel(
        id: json['_id'] ?? "",
        commentId: json['comment'] ?? "",
        creator: Creator.fromJson(json['creator'] ?? const <String, dynamic>{}),
        text: json['text'] ?? "",
        image: json['image'] ?? "",
        createdAt: json['createdAt'] ?? "",
        isCreator: json['isCreator'] ?? false,
      );
}

class Creator {
  final String id;
  final String name;
  final String image;
  Creator({required this.id, required this.name, required this.image});

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
    id: json['_id'] ?? "",
    name: json['name'] ?? "",
    image: json['image'] ?? "",
  );
}
