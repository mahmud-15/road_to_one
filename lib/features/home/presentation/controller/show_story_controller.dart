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
    final args = Get.arguments;
    final storyId = args?.toString() ?? '';
    if (storyId.trim().isEmpty) {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(AppString.someThingWrong)));
      }
      Get.back();
      return;
    }
    fetchStory(Get.context!, storyId);
  }

  void fetchStory(BuildContext context, String storyId) async {
    isLoading.value = true;
    update();
    try {
      final url = "${ApiEndPoint.storyUser}/$storyId";
      final response = await ApiService2.get(url);
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
          final temp = data['data']['data'] as List;
          if (temp.isEmpty) {
            return;
          } else {
            final userData = UserStoryModel.fromJson(temp.first);
            userStory.value = userData;
            update();
          }
        }
      }
    } catch (e) {
      errorLog("error in showStory: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void toggleStoryLike(int index) async {
    userStory.value!.stories[index].isLiked =
        !userStory.value!.stories[index].isLiked;
    update();
    final url =
        "${ApiEndPoint.story}/${userStory.value!.stories[index].id}/likes/toggle";
    try {
      await ApiService2.post(url, body: {});
    } catch (e) {
      errorLog("error in toggle like: $e");
    }
  }

  void sendMessage(BuildContext context, String text) async {
    final body = {"participant": userStory.value!.user.id, "text": text};
    final response = await ApiService2.post(
      ApiEndPoint.conversation,
      body: body,
    );
    if (response == null || response.statusCode != 201) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(AppString.someThingWrong)));
    }
  }
}
