class MealCategoryModel {
  final String id;
  final String title;
  final bool active;
  final int mealCount;

  MealCategoryModel({
    required this.id,
    required this.title,
    required this.active,
    required this.mealCount,
  });

  factory MealCategoryModel.fromJson(Map<String, dynamic> json) {
    final mealCount = json['mealCount'];
    return MealCategoryModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      active: json['active'] == true,
      mealCount: mealCount is num
          ? mealCount.toInt()
          : int.tryParse(mealCount?.toString() ?? '') ?? 0,
    );
  }
}
