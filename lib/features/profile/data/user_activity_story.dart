import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserActivityAllStory {
  List<UserActivityStory> userActivity;
  UserActivityAllStory({required this.userActivity});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userActivity': userActivity.map((x) => x.toMap()).toList(),
    };
  }

  factory UserActivityAllStory.fromMap(Map<String, dynamic> map) {
    return UserActivityAllStory(
      userActivity: List<UserActivityStory>.from(
        (map['userActivity'] as List<int>).map<UserActivityStory>(
          (x) => UserActivityStory.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserActivityAllStory.fromJson(String source) =>
      UserActivityAllStory.fromMap(json.decode(source) as Map<String, dynamic>);
}

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'creator': creator.toMap(),
      'caption': caption,
      'image': image,
      'media': media,
      'createAt': createAt,
    };
  }

  factory UserActivityStory.fromMap(Map<String, dynamic> map) {
    return UserActivityStory(
      id: map['_id'] ?? "",
      creator: Creator.fromMap(map['creator'] as Map<String, dynamic>),
      caption: map['caption'] as String,
      image: map['image'] as String,
      media: map['media'] as String,
      createAt: map['createAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserActivityStory.fromJson(String source) =>
      UserActivityStory.fromMap(json.decode(source) as Map<String, dynamic>);
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'role': role,
      'status': status,
      'verified': verified,
      'profileMode': profileMode,
      'createAt': createAt,
      'location': location,
    };
  }

  factory Creator.fromMap(Map<String, dynamic> map) {
    return Creator(
      id: map['id'] ?? "",
      name: map['name'] ?? "N/A",
      email: map['email'] ?? "",
      image: map['image'] ?? "",
      role: map['role'] ?? "",
      status: map['status'] ?? "",
      verified: map['verified'] ?? false,
      profileMode: map['profileMode'] ?? "",
      createAt: map['createAt'] ?? "",
      location: map['location'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory Creator.fromJson(String source) =>
      Creator.fromMap(json.decode(source) as Map<String, dynamic>);
}
