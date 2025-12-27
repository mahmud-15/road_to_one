import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginated_listview_builder/paginated_listview_builder.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/config/route/app_routes.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'package:road_project_flutter/utils/log/app_log.dart';
import 'package:road_project_flutter/utils/log/error_log.dart';
import 'dart:async';

import '../../../store/presentation/controller/cart_controller.dart';

import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../screen/comments_bottom_sheet.dart';

// Home Controller - Single controller for entire screen
class HomeController extends GetxController {
  final scrollController = ScrollController();
  final postPaginatedController = PaginatedController<PostModel>();
  final storyPaginationController = PaginatedController<StoryModel>();
  // Observable lists
  var stories = <StoryModel>[].obs;
  var posts = <PostModel>[].obs;
  var comments = <List<CommentModel>>[].obs;

  final storyLoading = false.obs;
  final postLoading = false.obs;
  final commentLoading = false.obs;

  // Notification counts
  var cartCount = 0.obs;
  var notificationCount = 0.obs;
  var messageCount = 5.obs;

  late final CartController _cartController;
  Worker? _cartCountWorker;

  // Post image carousel controllers
  final Map<String, PageController> pageControllers = {};
  final Map<String, RxInt> currentPages = {};
  final Map<String, Timer?> autoScrollTimers = {};

  void onRefresh() {}

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    _cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController(), permanent: true);

    cartCount.value = _cartController.cartCount.value;
    _cartCountWorker = ever<int>(_cartController.cartCount, (value) {
      cartCount.value = value;
      update();
    });

    fetchNotificationCount();

    initial(Get.context!);
  }

  Future<void> fetchNotificationCount() async {
    try {
      final response = await ApiService2.get(ApiEndPoint.notificationCount);
      if (response == null || response.statusCode != 200) {
        return;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      final raw = payload?['count'];
      if (raw is num) {
        notificationCount.value = raw.toInt();
      } else if (raw is String) {
        notificationCount.value = int.tryParse(raw) ?? 0;
      } else {
        notificationCount.value = 0;
      }
      update();
    } catch (_) {
      // ignore
    }
  }

  void initial(BuildContext context) {
    loadStories(context, 1);
    loadPosts(context, 1);
    initializePostControllers();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _cartCountWorker?.dispose();
    // Dispose all page controllers and timers
    for (var controller in pageControllers.values) {
      controller.dispose();
    }
    for (var timer in autoScrollTimers.values) {
      timer?.cancel();
    }

    super.onClose();
  }

  void loadStories(BuildContext context, int page) async {
    storyLoading.value = true;
    update();
    try {
      final url = "${ApiEndPoint.story}/?page=$page&limit=10";
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
          final temp = data['data'] as List;
          if (temp.isNotEmpty) {
            final userData = temp.map((e) => StoryModel.fromJson(e)).toList();
            storyPaginationController.addData(userData);
            stories.value = userData;
            update();
          }
        }
      }
    } catch (e) {
      errorLog("Load story failed: $e");
      Get.offAllNamed(AppRoutes.signIn);
    } finally {
      storyLoading.value = false;
      update();
    }
  }

  void loadPosts(BuildContext context, int page) async {
    postLoading.value = true;
    update();
    try {
      final url = "${ApiEndPoint.allPost}?page=$page&limit=10";
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
          final temp = data['data'] as List;
          if (temp.isNotEmpty) {
            final userData = temp.map((e) => PostModel.fromJson(e)).toList();
            appLog("userData: ${userData.length}");

            postPaginatedController.addData(userData);

            posts.value = userData;
            update();
          }
          // for (var c in posts) {
          //   loadComments(context, c.id);
          // }
        }
      }
    } catch (e) {
      errorLog("Load posts failed: $e");
      Get.offAllNamed(AppRoutes.signIn);
    } finally {
      postLoading.value = false;
      update();
    }
  }

  void loadComments(BuildContext context, String id) async {
    commentLoading.value = true;
    update();

    try {
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
          final userData = (data['data'] as List)
              .map((e) => CommentModel.fromJson(e))
              .toList();
          comments.add(userData);
          update();
        }
      }
    } catch (e) {
      errorLog("Load comments failed: $e");
      Get.offAllNamed(AppRoutes.signIn);
    } finally {
      commentLoading.value = false;
      update();
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
  void toggleLike(String postId) async {
    int index = posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      posts[index].isLiked = !posts[index].isLiked;
      posts.refresh();
      update();
      if (posts[index].isLiked) {
        posts[index].likeOfPost += 1;
      } else {
        posts[index].likeOfPost -= 1;
      }
      update();
      final url = "${ApiEndPoint.toggleLike}/$postId";
      try {
        await ApiService2.post(url, body: {});
      } catch (e) {
        errorLog("error in toggle like $e");
      }
    }
  }

  void onCommentTap(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsBottomSheet(postId: postId),
    );
  }

  void onSaveTap(BuildContext context, String postId) async {
    final url = "${ApiEndPoint.toggleSave}/$postId";
    final response = await ApiService2.post(url, body: {});
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
        int index = posts.indexWhere((post) => post.id == postId);
        posts[index].hasSave = !posts[index].hasSave;
        update();
      }
    }
  }

  void onCancelConnect(BuildContext context, PostModel post) async {
    final body = {"requestTo": post.creator.id};
    final response = await ApiService2.post(
      "${ApiEndPoint.sendRequest}/cancel",
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
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(data['message'])));
        posts
            .where((e) => e.creator.id == post.creator.id)
            .forEach((e) => e.connectionStatus = "not_requested");
        update();
      }
    }
  }

  void onConnectTap(BuildContext context, PostModel post) async {
    final body = {"requestTo": post.creator.id};
    final response = await ApiService2.post(
      ApiEndPoint.sendRequest,
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
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(data['message'])));
        posts
            .where((e) => e.creator.id == post.creator.id)
            .forEach((e) => e.connectionStatus = data['data']['status']);
        update();
      }
    }
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
