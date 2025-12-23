// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserStoryModel {
  final User user;
  final List<Story> stories;
  UserStoryModel({required this.user, required this.stories});

  factory UserStoryModel.fromJson(Map<String, dynamic> json) => UserStoryModel(
    user: User.fromJson(json['user']),
    stories: (json['stories'] as List).map((e) => Story.fromJson(e)).toList(),
  );
}

class User {
  final String id;
  final String name;
  final String image;
  User({required this.id, required this.name, required this.image});
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['_id'] ?? "",
    name: json['name'] ?? "",
    image: json['image'] ?? "",
  );
}

class Story {
  final String id;
  final String type;
  final String caption;
  final String image;
  final DateTime createAt;
  final bool isWatchStory;
  final bool isLiked;
  final int likeCount;
  Story({
    required this.id,
    required this.type,
    required this.caption,
    required this.image,
    required this.createAt,
    required this.isWatchStory,
    required this.isLiked,
    required this.likeCount,
  });

  factory Story.fromJson(Map<String, dynamic> json) => Story(
    id: json['_id'] ?? "",
    type: json['type'] ?? "",
    caption: json['caption'] ?? "",
    image: json['image'] ?? "",
    createAt: json['createAt'] ?? "",
    isWatchStory: json['isWatchStory'] ?? false,
    isLiked: json['isLiked'] ?? false,
    likeCount: json['likeCount'] ?? 0,
  );
}
