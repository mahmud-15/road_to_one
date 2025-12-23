import 'package:get/get.dart';

class PlanModel {
  final String id;
  final String title;
  final String? description;
  final String? image;
  final bool? looked;
  final RxBool isLocked;

  PlanModel({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.looked,
    required bool isLocked,
  }) : isLocked = isLocked.obs;

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final looked = json['looked'] as bool?;
    return PlanModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      looked: looked,
      isLocked: looked ?? false,
    );
  }
}