import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'constants/app_colors.dart';

class Utils {
  static String? commonValidator(String value) {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');

    if (!regex.hasMatch(value)) {
      return 'Only letters and numbers are allowed';
    } else {
      return null;
    }
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String timeAgo(DateTime givenTime) {
    final now = DateTime.now();
    final difference = now.difference(givenTime);

    if (difference.inSeconds < 60) {
      return "just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hr ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} day ago";
    } else {
      return "${(difference.inDays / 7).floor()} week ago";
    }
  }

  static successSnackBar(String title, String message) {
    Get.snackbar(
      title,
      message,
      colorText: AppColors.white,
      backgroundColor: AppColors.black,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static errorSnackBar(dynamic title, String message) {
    Get.snackbar(
      kDebugMode ? title.toString() : "Oops",
      message,
      colorText: AppColors.white,
      backgroundColor: AppColors.red,
      snackPosition: SnackPosition.TOP,
    );
  }
}
