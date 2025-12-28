import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/config/route/app_routes.dart';
import 'package:road_project_flutter/features/auth/change_password/presentation/widgets/success_dialog.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';

class SetPasswordController extends GetxController {
  final otp = "".obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    otp.value = Get.arguments;
  }

  void verifyPassword(
    BuildContext context, {
    required String newPassword,
    required String confirmPassword,
  }) async {
    final body = {
      "otp": otp.value,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    };
    final response = await ApiService2.post(
      ApiEndPoint.resetPassword,
      body: body,
    );

    if (response == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(AppString.someThingWrong)));
    } else {
      final data = response.data;
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(data['message'])));
      } else {
        // ScaffoldMessenger.of(context)
        //   ..clearSnackBars()
        //   ..showSnackBar(SnackBar(content: Text(data['message'])));
        SuccessDialog.show(context);
      }
    }
  }

  Future<void> changePassword(
    BuildContext context, {
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isLoading.value = true;
    update();
    try {
      final body = {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      };

      final response = await ApiService2.post(
        ApiEndPoint.changePassword,
        body: body,
      );

      if (response == null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(AppString.someThingWrong)));
        return;
      }

      final data = response.data;
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(data['message'].toString())));
        return;
      }

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(data['message'].toString())));
      Get.offAllNamed(AppRoutes.signIn);
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
