import 'package:get/get.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/meal_category_model.dart';

class MealCategoryController extends GetxController {
  final categories = <MealCategoryModel>[].obs;
  final isLoading = false.obs;

  int page = 1;
  int limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories({int? page, int? limit}) async {
    isLoading.value = true;
    try {
      final p = page ?? this.page;
      final l = limit ?? this.limit;
      final url = '${ApiEndPoint.mealAndRecipeCategory}?page=$p&limit=$l';

      final response = await ApiService2.get(url);
      if (response == null || response.statusCode != 200) {
        categories.clear();
        return;
      }

      final data = response.data;
      final list = (data is Map) ? (data['data'] as List?) : null;
      if (list == null) {
        categories.clear();
        return;
      }

      categories.assignAll(
        list
            .whereType<Map>()
            .map((e) => MealCategoryModel.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );
    } catch (_) {
      categories.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
