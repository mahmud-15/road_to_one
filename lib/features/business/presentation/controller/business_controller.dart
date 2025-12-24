import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/route/app_routes.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';

class BusinessController extends GetxController {
  // Observable list of plans with simple Map structure
  var plans = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  final numberOfToken = 0.obs;

  int page = 1;
  int limit = 10;
  int? totalPage;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
    fetchMyToken();
  }

  Future<void> fetchMyToken() async {
    try {
      final response = await ApiService2.get(ApiEndPoint.myToken);
      if (response == null || response.statusCode != 200) {
        numberOfToken.value = 0;
        return;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      final token = payload?['numberOfToken'];
      if (token is num) {
        numberOfToken.value = token.toInt();
      } else if (token is String) {
        numberOfToken.value = int.tryParse(token) ?? 0;
      } else {
        numberOfToken.value = 0;
      }
    } catch (_) {
      numberOfToken.value = 0;
    }
  }

  Future<void> fetchPlans({int? page, int? limit}) async {
    final p = page ?? this.page;
    final l = limit ?? this.limit;

    if (p <= 1) {
      isLoading.value = true;
      isLoadingMore.value = false;
      hasMore.value = true;
      totalPage = null;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final url = '${ApiEndPoint.businessAndMindsetPlan}?page=$p&limit=$l';
      final response = await ApiService2.get(url);

      if (response == null || response.statusCode != 200) {
        if (p <= 1) {
          plans.clear();
        }
        return;
      }

      final data = response.data;
      final list = (data is Map) ? (data['data'] as List?) : null;
      if (list == null) {
        if (p <= 1) {
          plans.clear();
        }
        return;
      }

      final pagination = (data is Map) ? (data['pagination'] as Map?) : null;
      final rawTotalPage = pagination?['totalPage'];
      if (rawTotalPage is num) {
        totalPage = rawTotalPage.toInt();
      } else if (rawTotalPage is String) {
        totalPage = int.tryParse(rawTotalPage);
      }

      final mapped = list.whereType<Map>().map((raw) {
        final item = raw.cast<String, dynamic>();
        final looked = item['looked'] as bool?;
        return <String, dynamic>{
          'id': (item['_id'] ?? item['id'] ?? '').toString(),
          'title': (item['title'] ?? '').toString(),
          'looked': looked,
          // looked: false => unlocked (isLocked=false)
          // looked: true  => locked   (isLocked=true)
          'isLocked': looked ?? false,
        };
      }).toList();

      if (p <= 1) {
        plans.assignAll(mapped);
      } else {
        plans.addAll(mapped);
      }

      this.page = p;
      this.limit = l;

      if (totalPage != null) {
        hasMore.value = p < totalPage!;
      } else {
        hasMore.value = mapped.length == l;
      }
    } catch (_) {
      if ((page ?? this.page) <= 1) {
        plans.clear();
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value) {
      return;
    }
    if (!hasMore.value) {
      return;
    }
    await fetchPlans(page: page + 1, limit: limit);
  }

  void openPlan(Map<String, dynamic> plan) {
    final planId = (plan['id'] ?? '').toString();
    Get.toNamed(AppRoutes.personalDetailsScreen, arguments: planId);
  }

  Future<void> onPlanTap(Map<String, dynamic> plan) async {
    final isLocked = plan['isLocked'] ?? false;
    if (!isLocked) {
      openPlan(plan);
      return;
    }

    if (numberOfToken.value <= 0) {
      Get.snackbar(
        'No Tokens',
        "You don't have enough tokens to open this plan.",
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        title: const Text(
          'Confirmation',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Opening this plan will use 1 token. Do you want to continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Agree',
              style: TextStyle(color: Color(0xFFb4ff39)),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    if (result == true) {
      numberOfToken.value = (numberOfToken.value - 1).clamp(0, 1 << 31);
      _unlockPlanInList((plan['id'] ?? '').toString());
      openPlan(plan);
    }
  }

  void _unlockPlanInList(String planId) {
    if (planId.isEmpty) {
      return;
    }

    final idx = plans.indexWhere((p) => (p['id'] ?? '').toString() == planId);
    if (idx == -1) {
      return;
    }

    plans[idx]['isLocked'] = false;
    plans[idx]['looked'] = false;
    plans.refresh();
  }

  void showLockedMessage() {
    Get.snackbar(
      'Locked',
      'This plan is currently locked. Complete previous plans to unlock.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  // Method to unlock a plan
  void unlockPlan(String planId) {
    final planIndex = plans.indexWhere((plan) => plan['id'] == planId);
    if (planIndex != -1) {
      plans[planIndex]['isLocked'] = false;
      plans.refresh(); // Refresh the observable list
    }
  }

  // Method to check if user can unlock next plan
  void checkAndUnlockNext(String completedPlanId) {
    final completedIndex = plans.indexWhere((plan) => plan['id'] == completedPlanId);
    if (completedIndex != -1 && completedIndex < plans.length - 1) {
      plans[completedIndex + 1]['isLocked'] = false;
      plans.refresh(); // Refresh the observable list
    }
  }

  // Check if a plan is locked
  bool isPlanLocked(Map<String, dynamic> plan) {
    return plan['isLocked'] ?? false;
  }
}