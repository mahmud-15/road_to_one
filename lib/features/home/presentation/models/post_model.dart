import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PostAllModel {
  List<PostModel> postModel;
  PostAllModel({required this.postModel});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'postModel': postModel.map((x) => x.toMap()).toList(),
    };
  }

  factory PostAllModel.fromMap(Map<String, dynamic> map) {
    return PostAllModel(
      postModel: List<PostModel>.from(
        (map['postModel'] as List<int>).map<PostModel>(
          (x) => PostModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory PostAllModel.fromJson(String source) =>
      PostAllModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class PostModel {
  final String id;
  final Creator creator;
  final String caption;
  final String type;
  final String createAt;
  final int commentOfPost;
  final int likeOfPost;
  final bool isOwner;
  final bool hasSave;
  bool isLiked;
  final String connectionStatus;
  final List<String> image;
  PostModel({
    required this.id,
    required this.creator,
    required this.caption,
    required this.type,
    required this.createAt,
    required this.commentOfPost,
    required this.likeOfPost,
    required this.isOwner,
    required this.hasSave,
    required this.isLiked,
    required this.connectionStatus,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'creator': creator.toMap(),
      'caption': caption,
      'type': type,
      'createAt': createAt,
      'commentOfPost': commentOfPost,
      'likeOfPost': likeOfPost,
      'isLiked': isLiked,
      'isOwner': isOwner,
      'hasSave': hasSave,
      'connectionStatus': connectionStatus,
      'image': image,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['_id'] as String,
      creator: Creator.fromMap(map['creator'] as Map<String, dynamic>),
      caption: map['caption'] as String,
      type: map['type'] as String,
      createAt: map['createAt'] as String,
      commentOfPost: map['commentOfPost'] as int,
      likeOfPost: map['likeOfPost'] as int,
      isLiked: map['isLiked'] ?? false,
      isOwner: map['isOwner'] as bool,
      hasSave: map['hasSave'] as bool,
      connectionStatus: map['connectionStatus'] as String,
      image: List<String>.from((map['image'] as List<String>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Creator {
  final String id;
  final String name;
  final String image;
  final String profileMode;
  Creator({
    required this.id,
    required this.name,
    required this.image,
    required this.profileMode,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'name': name,
      'image': image,
      'profileMode': profileMode,
    };
  }

  factory Creator.fromMap(Map<String, dynamic> map) {
    return Creator(
      id: map['_id'] as String,
      name: map['name'] as String,
      image: map['image'] as String,
      profileMode: map['profileMode'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Creator.fromJson(String source) =>
      Creator.fromMap(json.decode(source) as Map<String, dynamic>);
}
