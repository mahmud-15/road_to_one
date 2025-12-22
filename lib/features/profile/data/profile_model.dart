import 'dart:convert';

class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String image;
  final List<dynamic> preferences;
  final int totalPost;
  final int totalNetwork;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.preferences,
    required this.totalPost,
    required this.totalNetwork,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'preferences': preferences,
      'totalPost': totalPost,
      'totalNetwork': totalNetwork,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['_id'] ?? "",
      name: map['name'] ?? "N/A",
      email: map['email'] ?? "N/A",
      image: map['image'] ?? "",
      preferences: List<dynamic>.from((map['preferences'] ?? [])),
      totalPost: map['totalPost'] ?? 0,
      totalNetwork: map['totalNetwork'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) =>
      ProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
