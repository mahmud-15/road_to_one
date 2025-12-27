// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProfileModel {
  final String id;
  String name;
  String email;
  String image;
  final List<Preferences> preferences;
  final int totalPost;
  final int totalNetwork;
  String about;
  String mobile;
  String location;
  String occupation;
  String dreamJob;
  String education;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.preferences,
    required this.totalPost,
    required this.totalNetwork,
    required this.about,
    required this.mobile,
    required this.location,
    required this.occupation,
    required this.dreamJob,
    required this.education,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'] ?? "",
    name: json['name'] ?? "",
    email: json['email'] ?? "",
    image: json['image'] ?? "",
    about: json['about'] ?? "",
    preferences: (json['preferences'] as List)
        .map((e) => Preferences.fromJson(e))
        .toList(),
    totalPost: json['totalPost'] ?? 0,
    totalNetwork: json['totalNetwork'] ?? 0,
    dreamJob: json['dreamJob'] ?? "N/A",
    education: json['education'] ?? "",
    location: json['location'] ?? "",
    mobile: json['mobile'] ?? "",
    occupation: json['occupation'] ?? "N/A",
  );
}

class Preferences {
  String id;
  String name;
  bool active;
  Preferences({required this.id, required this.name, required this.active});
  factory Preferences.fromJson(Map<String, dynamic> json) => Preferences(
    id: json['_id'] ?? "",
    name: json['name'] ?? "",
    active: json['active'] == true,
  );
}
