import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../services/storage/storage_keys.dart';
import '../../../../../services/storage/storage_services.dart';

class SignInController extends GetxController {
  /// Sign in Button Loading variable
  final isLoading = false.obs;

  Future<void> signInUser(
    BuildContext context, {
    required String email,
    required String password,
    required bool isRememberMe,
  }) async {
    isLoading.value = true;
    update();

    Map<String, String> body = {
      "email": email,
      "password": password,
      "auth_provider": "local",
    };
    // email: sodabo6181@roratu.com

    var response = await ApiService2.post(ApiEndPoint.signIn, body: body);

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
        LocalStorage.token = data['data']['accessToken'];
        LocalStorage.userId = data['data']['userInfo']['_id'];
        LocalStorage.profileImage = data['data']['userInfo']['profileImage'];

        if (isRememberMe) {
          LocalStorage.setString(LocalStorageKeys.token, LocalStorage.token);
          LocalStorage.isLogIn = true;
          LocalStorage.setBool(LocalStorageKeys.isLogIn, LocalStorage.isLogIn);
          LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId);
          LocalStorage.setString(
            LocalStorageKeys.profileImage,
            LocalStorage.profileImage,
          );
        }
        // profile data need to be used later
        Get.offAllNamed(AppRoutes.homeNav);
      }
    }
  }
}
