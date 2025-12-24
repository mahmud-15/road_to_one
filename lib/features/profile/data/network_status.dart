enum NetworkStatus { pending, accepted, rejected }

class NetworkUser {
  String id;
  User user;
  NetworkStatus status;
  DateTime createAt;
  NetworkUser({
    required this.id,
    required this.user,
    required this.status,
    required this.createAt,
  });

  factory NetworkUser.fromJson(Map<String, dynamic> json) => NetworkUser(
    id: json['_id'] ?? "",
    user: User.fromJson(json['user']),
    status: json['status'] ?? "",
    createAt: json['createAt'] ?? "",
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
