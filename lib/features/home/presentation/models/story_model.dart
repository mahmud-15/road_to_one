class StoryModel {
  final String id;
  final String name;
  final String image;
  final int storyCount;
  final int priority;
  final bool isWatched;
  final String connectionStatus;
  StoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.storyCount,
    required this.priority,
    required this.isWatched,
    required this.connectionStatus,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
    id: json['_id'] ?? "",
    name: json['name'] ?? "",
    image: json['image'] ?? "",
    storyCount: json['storyCount'] ?? 0,
    priority: json['priority'] ?? 0,
    isWatched: json['isWatched'] ?? false,
    connectionStatus: json['connectionStatus'] ?? "",
  );
}
