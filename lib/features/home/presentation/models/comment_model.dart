import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CommentModelAll {
  List<CommentModel> comments;
  CommentModelAll({required this.comments});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'comments': comments.map((x) => x.toMap()).toList(),
    };
  }

  factory CommentModelAll.fromMap(Map<String, dynamic> map) {
    return CommentModelAll(
      comments: List<CommentModel>.from(
        (map['comments'] as List<int>).map<CommentModel>(
          (x) => CommentModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentModelAll.fromJson(String source) =>
      CommentModelAll.fromMap(json.decode(source) as Map<String, dynamic>);
}

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'creator': creator.toMap(),
      'text': text,
      'createAt': createAt,
      'isLiked': isLiked,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['_id'] as String,
      creator: Creator.fromMap(map['creator'] as Map<String, dynamic>),
      text: map['text'] as String,
      createAt: map['createAt'] as String,
      isLiked: map['isLiked'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentModel.fromJson(String source) =>
      CommentModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Creator {
  final String id;
  final String name;
  final String image;
  Creator({required this.id, required this.name, required this.image});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'_id': id, 'name': name, 'image': image};
  }

  factory Creator.fromMap(Map<String, dynamic> map) {
    return Creator(
      id: map['_id'] as String,
      name: map['name'] as String,
      image: map['image'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Creator.fromJson(String source) =>
      Creator.fromMap(json.decode(source) as Map<String, dynamic>);
}
