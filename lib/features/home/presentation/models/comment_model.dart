class CommentModel {
  final String id;
  final Creator creator;
  final String text;
  final String createAt;
  final bool isLiked;
  CommentModel({
    required this.id,
    required this.creator,
    required this.text,
    required this.createAt,
    required this.isLiked,
  });
  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['_id'] ?? "",
    creator: Creator.fromJson(json['creator']),
    text: json['text'] ?? "",
    createAt: json['createAt'] ?? "",
    isLiked: json['isLiked'] ?? false,
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
