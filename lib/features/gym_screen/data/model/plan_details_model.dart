import '../../../../config/api/api_end_point.dart';

class PlanDetailModel {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final List<String> benefits;

  PlanDetailModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    this.benefits = const <String>[],
  });

  factory PlanDetailModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? '';
    final imageUrl = rawImage.startsWith('http')
        ? rawImage
        : (rawImage.isNotEmpty ? '${ApiEndPoint.imageUrl}$rawImage' : '');

    final benefitsJson = json['benefits'];
    final benefits = (benefitsJson is List)
        ? benefitsJson.map((e) => e.toString()).toList()
        : const <String>[];

    return PlanDetailModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      imageUrl: imageUrl,
      description: (json['description'] ?? '').toString(),
      benefits: benefits,
    );
  }
}