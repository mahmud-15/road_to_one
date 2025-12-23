import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';

import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';

class SignUpController extends GetxController {
  final isLoading = false.obs;
  final isLoadingVerify = false.obs;

  signUpUser(
    BuildContext context, {
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    isLoading.value = true;
    update();
    Map<String, String> body = {
      "name": name,
      "email": email,
      "password": password,
      "confirm_password": confirmPassword,
      "auth_provider": "local",
    };

    final response = await ApiService2.post(
      ApiEndPoint.signUp,
      body: body,
      header: {"Content-Type": "application/json"},
    );
    isLoading.value = false;
    update();
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
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(data['message'])));
        Get.toNamed(AppRoutes.verifyUser, arguments: email);
      }
    }
  }
}
