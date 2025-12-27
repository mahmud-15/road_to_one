class StoreCollectionModel {
  final String id;
  final String title;
  final String handle;

  StoreCollectionModel({
    required this.id,
    required this.title,
    required this.handle,
  });

  factory StoreCollectionModel.fromJson(Map<String, dynamic> json) {
    return StoreCollectionModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      handle: (json['handle'] ?? '').toString(),
    );
  }
}
