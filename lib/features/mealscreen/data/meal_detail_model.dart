class MealDetailModel {
  final String id;
  final String name;
  final String imageUrl;
  final String description;

  MealDetailModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  factory MealDetailModel.fromJson(
    Map<String, dynamic> json, {
    required String baseImageUrl,
  }) {
    final rawImage = json['image']?.toString() ?? '';
    final imageUrl = rawImage.startsWith('http')
        ? rawImage
        : (rawImage.isNotEmpty ? '$baseImageUrl$rawImage' : '');

    return MealDetailModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      imageUrl: imageUrl,
      description: (json['description'] ?? '').toString(),
    );
  }
}
