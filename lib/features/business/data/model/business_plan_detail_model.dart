class BusinessPlanDetailModel {
  final String id;
  final String title;
  final String description;

  BusinessPlanDetailModel({
    required this.id,
    required this.title,
    required this.description,
  });

  factory BusinessPlanDetailModel.fromJson(Map<String, dynamic> json) {
    return BusinessPlanDetailModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}
