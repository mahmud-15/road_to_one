import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'dart:async';

import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';

// Home Controller - Single controller for entire screen
class HomeController extends GetxController {
  final scrollController = ScrollController();

  // Observable lists
  var stories = <StoryModel>[].obs;
  var posts = <PostModel>[].obs;
  var comments = <List<CommentModel>>[].obs;

  // Notification counts
  var cartCount = 3.obs;
  var notificationCount = 1.obs;
  var messageCount = 5.obs;

  // Post image carousel controllers
  final Map<String, PageController> pageControllers = {};
  final Map<String, RxInt> currentPages = {};
  final Map<String, Timer?> autoScrollTimers = {};

  void onRefresh() {}

  void initial(BuildContext context) {
    loadStories(context);
    loadPosts(context);
    initializePostControllers();
  }

  @override
  void onClose() {
    scrollController.dispose();
    // Dispose all page controllers and timers
    for (var controller in pageControllers.values) {
      controller.dispose();
    }
    for (var timer in autoScrollTimers.values) {
      timer?.cancel();
    }
    super.onClose();
  }

  void loadStories(BuildContext context) async {
    final response = await ApiService2.get(ApiEndPoint.story);
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
        final userData = StoryModelAll.fromJson(data['data']);
        stories.value = userData.stories;
        update();
      }
    }
  }

  void loadPosts(BuildContext context) async {
    final response = await ApiService2.get(ApiEndPoint.allPost);
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
        final userData = PostAllModel.fromJson(data['data']);
        posts.value = userData.postModel;
        update();
        for (var c in posts) {
          loadComments(context, c.id);
        }
      }
    }
  }

  void loadComments(BuildContext context, String id) async {
    final url = "${ApiEndPoint.allComment}/$id";
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
        final userData = CommentModelAll.fromJson(data['data']);
        comments.add(userData.comments);
        update();
      }
    }
  }

  void initializePostControllers() {
    for (var post in posts) {
      if (!pageControllers.containsKey(post.id)) {
        pageControllers[post.id] = PageController();
        currentPages[post.id] = 0.obs;

        // Start auto scroll for posts with multiple images
        if (post.image.length > 1) {
          startAutoScroll(post.id, post.image.length);
        }
      }
    }
  }

  void startAutoScroll(String postId, int imageCount) {
    autoScrollTimers[postId] = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) {
      if (currentPages[postId] != null && pageControllers[postId] != null) {
        int nextPage = (currentPages[postId]!.value + 1) % imageCount;
        currentPages[postId]!.value = nextPage;

        if (pageControllers[postId]!.hasClients) {
          pageControllers[postId]!.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
      }
    });
  }

  void onPageChanged(String postId, int page) {
    if (currentPages[postId] != null) {
      currentPages[postId]!.value = page;
    }
  }

  // App bar actions
  void onCartTap() {
    Get.snackbar('Cart', 'Cart clicked');
  }

  void onNotificationTap() {
    Get.snackbar('Notifications', 'Notifications clicked');
  }

  void onMessageTap() {
    Get.snackbar('Messages', 'Messages clicked');
  }

  // Post actions
  void toggleLike(String postId) {
    int index = posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      posts[index].isLiked = !posts[index].isLiked;
      posts.refresh();
    }
  }

  void onCommentTap(String postId) {
    Get.snackbar('Comment', 'Comment on post $postId');
  }

  void onSaveTap(String postId) {
    Get.snackbar('Save', 'Post $postId saved');
  }

  void onConnectTap(String userName) {
    Get.snackbar('Connect', 'Connected with $userName');
  }

  void onMoreTap(String postId) {
    Get.snackbar('More', 'More options for post $postId');
  }

  // Get page controller for a post
  PageController? getPageController(String postId) {
    return pageControllers[postId];
  }

  // Get current page for a post
  RxInt? getCurrentPage(String postId) {
    return currentPages[postId];
  }
}
