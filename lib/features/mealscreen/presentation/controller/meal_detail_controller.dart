import 'package:get/get.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/meal_detail_model.dart';

class MealDetailController extends GetxController {
  final isLoading = false.obs;
  final mealDetail = Rxn<MealDetailModel>();

  String mealId = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      mealId = args.toString();
    }

    fetchMealDetail();
  }

  Future<void> fetchMealDetail() async {
    if (mealId.isEmpty) {
      mealDetail.value = null;
      return;
    }

    isLoading.value = true;
    try {
      final url = '${ApiEndPoint.meal}/$mealId';
      final response = await ApiService2.get(url);
      if (response == null || response.statusCode != 200) {
        mealDetail.value = null;
        return;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      if (payload == null) {
        mealDetail.value = null;
        return;
      }

      mealDetail.value = MealDetailModel.fromJson(
        payload.cast<String, dynamic>(),
        baseImageUrl: ApiEndPoint.imageUrl,
      );
    } catch (_) {
      mealDetail.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
