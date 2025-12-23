import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/route/app_routes.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/details_all_model.dart';

class BreakfastController extends GetxController {
  final meals = <MealItem>[].obs;
  final isLoading = false.obs;
  final numberOfToken = 0.obs;

  String mealType = "";
  String categoryId = "";

  int page = 1;
  int limit = 10;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args is Map) {
      categoryId = (args['id'] ?? '').toString();
      mealType = (args['title'] ?? '').toString();
    }

    if (mealType.isEmpty) {
      mealType = 'Meals';
    }

    fetchMyToken();
    fetchMeals();
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

  Future<void> fetchMeals({int? page, int? limit}) async {
    if (categoryId.isEmpty) {
      meals.clear();
      return;
    }

    isLoading.value = true;
    try {
      final p = page ?? this.page;
      final l = limit ?? this.limit;
      final url = '${ApiEndPoint.mealAll}/$categoryId?page=$p&limit=$l';
      final response = await ApiService2.get(url);
      if (response == null || response.statusCode != 200) {
        meals.clear();
        return;
      }

      final data = response.data;
      final list = (data is Map) ? (data['data'] as List?) : null;
      if (list == null) {
        meals.clear();
        return;
      }

      meals.assignAll(
        list
            .whereType<Map>()
            .map((e) => MealItem.fromJson(
                  e.cast<String, dynamic>(),
                  baseImageUrl: ApiEndPoint.imageUrl,
                ))
            .toList(),
      );
    } catch (_) {
      meals.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void onMealTap(int index) {
    if (!meals[index].isLocked.value) {
      openMealDetail(meals[index]);
      return;
    }

    onLockedMealTap(meals[index]);
  }

  void openMealDetail(MealItem meal) {
    Get.toNamed(AppRoutes.mealDetailScreen, arguments: meal.id);
    // Navigate to meal detail screen
    // Get.to(() => MealDetailScreen(meal: meal));
  }

  Future<void> onLockedMealTap(MealItem meal) async {
    if (numberOfToken.value <= 0) {
      Get.snackbar(
        'No Tokens',
        "You don't have enough tokens to open this meal.",
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
          'Opening this meal will use 1 token. Do you want to continue?',
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
      openMealDetail(meal);
    }
  }

  void showLockedMessage(String mealName) {
    Get.snackbar(
      'Locked',
      '$mealName is locked. Complete previous meals to unlock.',
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: Icon(Icons.lock, color: Colors.white),
    );
  }

  void unlockMeal(int index) {
    if (index >= 0 && index < meals.length) {
      meals[index].isLocked.value = false;
      Get.snackbar(
        'Unlocked!',
        '${meals[index].name} is now unlocked',
        backgroundColor: const Color(0xFFb4ff39),
        colorText: Colors.black,
        duration: const Duration(seconds: 2),
        icon: Icon(Icons.lock_open, color: Colors.black),
      );
    }
  }

  void unlockMealById(String mealId) {
    final index = meals.indexWhere((m) => m.id == mealId);
    if (index != -1) {
      unlockMeal(index);
    }
  }

  void unlockNextMeal() {
    final index = meals.indexWhere((m) => m.isLocked.value == true);
    if (index != -1) {
      unlockMeal(index);
    }
  }

  void lockMeal(int index) {
    if (index >= 0 && index < meals.length) {
      meals[index].isLocked.value = true;
    }
  }
}