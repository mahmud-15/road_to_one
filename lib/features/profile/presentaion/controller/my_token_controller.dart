import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/services/api/api_service.dart';

class MyTokenController extends GetxController {
  final isLoading = false.obs;
  final tokenCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyToken();
  }

  Future<void> fetchMyToken() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final response = await ApiService2.get(ApiEndPoint.myToken);
      if (response == null || response.statusCode != 200) {
        tokenCount.value = 0;
        return;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      final raw = payload?['numberOfToken'];
      if (raw is num) {
        tokenCount.value = raw.toInt();
      } else if (raw is String) {
        tokenCount.value = int.tryParse(raw) ?? 0;
      } else {
        tokenCount.value = 0;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
