import 'package:get/get.dart';

class MealItem {
  final String id;
  final String name;
  final String imageUrl;
  final String? description;
  final RxBool isLocked;

  MealItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
    required bool isLocked,
  }) : isLocked = isLocked.obs;

  factory MealItem.fromJson(Map<String, dynamic> json, {required String baseImageUrl}) {
    final looked = json['looked'] as bool?;
    final rawImage = json['image']?.toString() ?? '';
    final imageUrl = rawImage.startsWith('http')
        ? rawImage
        : (rawImage.isNotEmpty ? '$baseImageUrl$rawImage' : '');

    return MealItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      imageUrl: imageUrl,
      description: json['description']?.toString(),
      isLocked: looked ?? false,
    );
  }
}