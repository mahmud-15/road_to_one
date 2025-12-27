import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/route/app_routes.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/model/my_plan_model.dart';

class MyPlanController extends GetxController {
  final plans = <PlanModel>[].obs;
  final isLoading = false.obs;
  final numberOfToken = 0.obs;
  int page = 1;
  int limit = 10;

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
    isLoading.value = true;
    try {
      final p = page ?? this.page;
      final l = limit ?? this.limit;
      final url = '${ApiEndPoint.gymAndFitnessPlan}?page=$p&limit=$l';
      final response = await ApiService2.get(url);

      if (response == null || response.statusCode != 200) {
        plans.clear();
        return;
      }

      final data = response.data;
      final list = (data is Map) ? (data['data'] as List?) : null;
      if (list == null) {
        plans.clear();
        return;
      }

      plans.assignAll(
        list
            .whereType<Map>()
            .map((e) => PlanModel.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );
    } catch (_) {
      plans.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void openPlan(PlanModel plan) {
    Get.toNamed(AppRoutes.planDetails, arguments: plan.id);
    // Navigate to plan detail screen
    // Get.to(() => PlanDetailScreen(plan: plan));
  }

  Future<void> onPlanTap(PlanModel plan) async {
    if (!plan.isLocked.value) {
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
      _unlockPlanInList(plan.id);
      openPlan(plan);
    }
  }

  void _unlockPlanInList(String planId) {
    if (planId.isEmpty) {
      return;
    }

    final idx = plans.indexWhere((p) => p.id == planId);
    if (idx == -1) {
      return;
    }

    plans[idx].isLocked.value = false;
    plans.refresh();
  }

  void showLockedMessage() {
    Get.snackbar(
      'Locked',
      'This plan is locked. Complete previous plans to unlock.',
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: Icon(Icons.lock, color: Colors.white),
    );
  }

  void unlockPlan(String planId) {
    final plan = plans.firstWhere((p) => p.id == planId);
    plan.isLocked.value = false;
  }

  void lockPlan(String planId) {
    final plan = plans.firstWhere((p) => p.id == planId);
    plan.isLocked.value = true;
  }

  void unlockNextPlan() {
    // Unlock the next locked plan
    final lockedPlan = plans.firstWhereOrNull((p) => p.isLocked.value == true);
    if (lockedPlan != null) {
      lockedPlan.isLocked.value = false;
      Get.snackbar(
        'Plan Unlocked!',
        '${lockedPlan.title} is now unlocked',
        backgroundColor: const Color(0xFFb4ff39),
        colorText: Colors.black,
        duration: const Duration(seconds: 2),
        icon: Icon(Icons.lock_open, color: Colors.black),
      );
    }
  }
}
