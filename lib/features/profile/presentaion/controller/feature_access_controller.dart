import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/services/api/api_service.dart';

class FeatureAccessController extends GetxController {
  final isLoading = false.obs;
  final canAccessFeature = true.obs;

  DateTime? _optimisticUntil;

  void setAccess(bool value) {
    canAccessFeature.value = value;
    if (value) {
      _optimisticUntil = DateTime.now().add(const Duration(minutes: 2));
    } else {
      _optimisticUntil = null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAccess();
  }

  Future<void> fetchAccess() async {
    isLoading.value = true;
    try {
      final response = await ApiService2.get(ApiEndPoint.user);
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        final access = (data is Map && data['data'] is Map)
            ? (data['data']['canAccessFeature'] == true)
            : true;
        if (access == true) {
          _optimisticUntil = null;
          canAccessFeature.value = true;
        } else {
          final optimistic = _optimisticUntil != null &&
              DateTime.now().isBefore(_optimisticUntil!);
          if (!optimistic) {
            canAccessFeature.value = false;
          }
        }
      }
    } finally {
      isLoading.value = false;
    }
  }
}
