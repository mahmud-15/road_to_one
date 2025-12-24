class UserActivityStory {
  final String id;
  final Creator creator;
  final String caption;
  final String image;
  final String media;
  final String createAt;
  UserActivityStory({
    required this.id,
    required this.creator,
    required this.caption,
    required this.image,
    required this.media,
    required this.createAt,
  });

  factory UserActivityStory.fromJson(Map<String, dynamic> json) =>
      UserActivityStory(
        id: json['_id'] ?? "",
        creator: Creator.fromJson(json['creator']),
        caption: json['caption'] ?? "",
        image: json['image'] ?? "",
        media: json['media'] ?? "",
        createAt: json['createAt'] ?? "",
      );
}

class Creator {
  final String id;
  final String name;
  final String email;
  final String image;
  final String role;
  final String status;
  final bool verified;
  final String profileMode;
  final String createAt;
  final String location;

  Creator({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.role,
    required this.status,
    required this.verified,
    required this.profileMode,
    required this.createAt,
    required this.location,
  });

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
    id: json['_id'] ?? "",
    name: json['name'] ?? "",
    email: json['email'] ?? "",
    image: json['image'] ?? "",
    role: json['role'] ?? "",
    status: json['status'] ?? "",
    verified: json['verified'] ?? false,
    profileMode: json['profileMode'] ?? "",
    createAt: json['createAt'] ?? "",
    location: json['location'] ?? "",
  );
}
