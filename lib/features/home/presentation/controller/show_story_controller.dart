import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/features/home/presentation/models/user_story_model.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'package:road_project_flutter/utils/log/error_log.dart';

class ShowStoryController extends GetxController {
  final userStory = Rxn<UserStoryModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchStory(Get.context!);
  }

  void fetchStory(BuildContext context) async {
    isLoading.value = true;
    update();
    try {
      final response = await ApiService2.get(ApiEndPoint.storyUser);
      if (response == null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(AppString.someThingWrong)));
        Get.back();
      } else {
        final data = response.data;
        if (response.statusCode != 200) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(data['message'])));
          Get.back();
        } else {
          final userData = UserStoryModel.fromJson(data['data'][0]);
          userStory.value = userData;
          update();
        }
      }
    } catch (e) {
      errorLog("error in showStory: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
