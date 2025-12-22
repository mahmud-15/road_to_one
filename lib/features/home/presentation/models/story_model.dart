import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class StoryModelAll {
  List<StoryModel> stories;
  StoryModelAll({required this.stories});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'stories': stories.map((x) => x.toMap()).toList()};
  }

  factory StoryModelAll.fromMap(Map<String, dynamic> map) {
    return StoryModelAll(
      stories: List<StoryModel>.from(
        (map['stories'] as List<int>).map<StoryModel>(
          (x) => StoryModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory StoryModelAll.fromJson(String source) =>
      StoryModelAll.fromMap(json.decode(source) as Map<String, dynamic>);
}

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'name': name,
      'image': image,
      'storyCount': storyCount,
      'priority': priority,
      'isWatched': isWatched,
      'connectionStatus': connectionStatus,
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      id: map['_id'] as String,
      name: map['name'] as String,
      image: map['image'] as String,
      isWatched: map['isWatched'] ?? false,
      storyCount: map['storyCount'] as int,
      priority: map['priority'] as int,
      connectionStatus: map['connectionStatus'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoryModel.fromJson(String source) =>
      StoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
