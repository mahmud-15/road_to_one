import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/app_storage/storage_key.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/features/home/presentation/models/post_model.dart';
import 'package:road_project_flutter/features/profile/data/profile_model.dart';
import 'package:road_project_flutter/features/profile/data/user_activity_like.dart';
import 'package:road_project_flutter/features/profile/data/user_activity_model.dart';
import 'package:road_project_flutter/features/profile/data/user_activity_photo.dart';
import 'package:road_project_flutter/features/profile/data/user_activity_save.dart';
import 'package:road_project_flutter/features/profile/data/user_activity_story.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/services/storage/storage_services.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'package:road_project_flutter/utils/log/error_log.dart';

import '../../data/media_item.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;
  final imageLoading = false.obs;
  final likeLoading = false.obs;
  final storyLoading = false.obs;
  final saveLoading = false.obs;
  final user = Rxn<ProfileModel>();
  final userImage = RxList<UserActivityModel>();
  final userStory = RxList<UserActivityModel>();
  final userLike = RxList<UserActivityModel>();
  final userSave = RxList<UserActivityModel>();
  // final String username = "Alex Peterson";
  final String bio =
      "Job: UI/UX Designer\nDream Job: UI/UX Designer\nInterested in Socializing, Adventure, Travelling";
  // final int postsCount = 33;
  // final int networkCount = 483;
  final String profileImage =
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop";

  // Real photos from Unsplash and videos from sample sources
  final List<MediaItem> posts = [
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      type: UserMediaType.video,
      duration: "0:15",
      thumbnail:
          "https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?w=400&h=400&fit=crop",
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      type: UserMediaType.video,
      duration: "1:23",
      thumbnail:
          "https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400&h=400&fit=crop",
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1583468982228-19f19164aee2?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1590086782792-42dd2350140d?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      type: UserMediaType.video,
      duration: "2:15",
      thumbnail:
          "https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400&h=400&fit=crop",
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
  ];

  final List<MediaItem> stories = [
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
      type: UserMediaType.video,
      duration: "0:15",
      thumbnail:
          "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&h=400&fit=crop",
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1583468982228-19f19164aee2?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
      type: UserMediaType.video,
      duration: "0:30",
      thumbnail:
          "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop",
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
  ];

  final List<MediaItem> favorites = [
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
      type: UserMediaType.video,
      duration: "1:05",
      thumbnail:
          "https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=400&h=400&fit=crop",
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1590086782792-42dd2350140d?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
  ];

  final List<MediaItem> saved = [
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
      type: UserMediaType.video,
      duration: "3:20",
      thumbnail:
          "https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?w=400&h=400&fit=crop",
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
      type: UserMediaType.video,
      duration: "0:58",
      thumbnail:
          "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=400&fit=crop",
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1583468982228-19f19164aee2?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
    MediaItem(
      url:
          "https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=400&h=400&fit=crop",
      type: UserMediaType.image,
    ),
  ];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initial(Get.context!);
  }

  void initial(BuildContext context) {
    fetchProfile(context);
    fetchAllImage(context);
    fetchPost(context);
    fetchStory(context);
    fetchSave(context);
  }

  void fetchProfile(BuildContext context) async {
    isLoading.value = true;
    update();
    try {
      final response = await ApiService2.get(ApiEndPoint.user);

      if (response == null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(AppString.someThingWrong)));
      } else {
        final data = response.data;
        if (response.statusCode != 200) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(AppString.someThingWrong)));
        } else {
          final profileData = ProfileModel.fromJson(data['data']);
          user.value = profileData;
          update();
        }
      }
    } catch (e) {
      errorLog("error in profile: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void fetchAllImage(BuildContext context) async {
    imageLoading.value = true;
    update();
    try {
      final url =
          "${ApiEndPoint.userActivity}/${LocalStorage.userId}?type=photo";
      final response = await ApiService2.get(url);
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
          final userData = (data['data'] as List)
              .map((e) => UserActivityPhoto.fromJson(e))
              .toList();
          if (userData.isNotEmpty) {
            userImage.value = userData
                .map(
                  (e) => UserActivityModel(
                    file: e.type == 'image' ? e.image[0] : e.media[0],
                    type: e.type,
                  ),
                )
                .toList();
          }
          update();
        }
      }
    } catch (e) {
      errorLog("error in image: $e");
    } finally {
      imageLoading.value = false;
      update();
    }
  }

  void fetchStory(BuildContext context) async {
    storyLoading.value = true;
    update();
    try {
      final url =
          "${ApiEndPoint.userActivity}/${LocalStorage.userId}?type=story";
      final response = await ApiService2.get(url);
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
          final userData = (data['data'] as List)
              .map((e) => UserActivityStory.fromJson(e))
              .toList();
          if (userData.isNotEmpty) {
            userStory.value = userData
                .map((e) => UserActivityModel(file: e.image, type: 'image'))
                .toList();
          }
          update();
        }
      }
    } catch (e) {
      errorLog("error in story: $e");
    } finally {
      storyLoading.value = false;
      update();
    }
  }

  void fetchPost(BuildContext context) async {
    likeLoading.value = true;
    update();
    try {
      final url =
          "${ApiEndPoint.userActivity}/${LocalStorage.userId}?type=like";
      final response = await ApiService2.get(url);
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
          final userData = (data['data'] as List)
              .map((e) => UserActivityLike.fromJson(e))
              .toList();
          if (userData.isNotEmpty) {
            userLike.value = userData
                .map(
                  (e) =>
                      UserActivityModel(file: e.post!.image[0], type: 'image'),
                )
                .toList();
          }
          update();
        }
      }
    } catch (e) {
      errorLog("error in post: $e");
    } finally {
      likeLoading.value = false;
      update();
    }
  }

  void fetchSave(BuildContext context) async {
    saveLoading.value = true;
    update();
    final url = "${ApiEndPoint.userActivity}/${LocalStorage.userId}?type=save";
    try {
      final response = await ApiService2.get(url);
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
          final userdata = (data['data'] as List)
              .map((e) => UserActivitySave.fromJson(e))
              .toList();
          if (userdata.isNotEmpty) {
            userSave.value = userdata
                .map(
                  (e) => UserActivityModel(
                    file: e.post.image.first,
                    type: 'image',
                  ),
                )
                .toList();
          }
          update();
        }
      }
    } catch (e) {
      errorLog("error in fetch save: $e");
    } finally {
      saveLoading.value = false;
      update();
    }
  }
}
