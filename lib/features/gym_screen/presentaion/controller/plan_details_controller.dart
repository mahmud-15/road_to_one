import 'package:get/get.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/model/plan_details_model.dart';

class PlanDetailController extends GetxController {

  final isLoading = true.obs;
  final Rx<PlanDetailModel?> planDetail = Rx<PlanDetailModel?>(null);


  @override
  void onInit() {
    super.onInit();
    loadPlanDetail();
  }

  void loadPlanDetail() async {
    isLoading.value = true;

    try {
      final planId = Get.arguments?.toString();
      if (planId == null || planId.isEmpty) {
        planDetail.value = null;
        return;
      }

      final url = '${ApiEndPoint.gymAndFitnessPlan}/$planId';
      final response = await ApiService2.get(url);
      if (response == null || response.statusCode != 200) {
        planDetail.value = null;
        return;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      if (payload == null) {
        planDetail.value = null;
        return;
      }

      planDetail.value = PlanDetailModel.fromJson(payload.cast<String, dynamic>());
    } catch (_) {
      planDetail.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}