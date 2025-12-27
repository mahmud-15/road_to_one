// ignore_for_file: public_member_api_docs, sort_constructors_first
class NotificationItem {
  final String id;
  final String receiver;
  final Sender? sender;
  final String title;
  final String message;
  final String refId;
  final String path;
  bool seen;
  final DateTime createdAt;
  NotificationItem({
    required this.id,
    required this.receiver,
    required this.sender,
    required this.title,
    required this.message,
    required this.refId,
    required this.path,
    required this.seen,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['_id'] ?? "",
        receiver: json['receiver'] ?? "",
        sender: Sender.fromJson(json['sender'] ?? {}),
        title: json['title'] ?? "",
        message: json['message'] ?? "",
        refId: json['refId'] ?? "",
        path: json['path'] ?? "",
        seen: json['seen'] ?? false,
        createdAt: DateTime.parse(json['createdAt'].toString()),
      );
}

class Sender {
  final String id;
  final String name;
  final String image;
  Sender({required this.id, required this.name, required this.image});
  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
    id: json['_id'] ?? "",
    name: json['name'] ?? "",
    image: json['image'] ?? "",
  );
}
