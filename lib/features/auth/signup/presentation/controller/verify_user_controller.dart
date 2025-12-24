import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/services/storage/storage_keys.dart';
import 'package:road_project_flutter/services/storage/storage_services.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';

class VerifyUserController extends GetxController {
  final email = "".obs;
  final isLoading = false.obs;
  final otpCode = "".obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final String args = Get.arguments;
    email.value = _maskEmail(args);
  }

  String _maskEmail(String email, {int visibleChars = 3}) {
    final parts = email.split('@');
    if (parts.length != 2) return email; // invalid email, return as is

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= visibleChars) {
      return email; // nothing to mask
    }

    final maskedUsername =
        '*' * (username.length - visibleChars) +
        username.substring(username.length - visibleChars);
    return '$maskedUsername@$domain';
  }

  void updateOTPFromTextField(String value) {
    if (value.length <= 6) {
      otpCode.value = value;
    }
  }

  void verifyOTP(BuildContext context) async {
    if (otpCode.value.length == 6) {
      isLoading.value = true;
      update();
      final body = {"otp": otpCode.value};
      final response = await ApiService2.post(
        ApiEndPoint.verifyEmail,
        body: body,
        header: {},
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
          LocalStorage.token = data['data'];
          LocalStorage.setString(LocalStorageKeys.token, LocalStorage.token);
          // navigate to home screen
        }
      }
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text("Please enter complete 6-digit OTP")),
        );
      // Get.snackbar(
      //   'Error',
      //   'Please enter complete 6-digit OTP',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red.withOpacity(0.7),
      //   colorText: Colors.white,
      //   margin: const EdgeInsets.all(16),
      // );
    }
  }
}
