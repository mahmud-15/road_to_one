import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paginated_listview_builder/paginated_listview_builder.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/config/route/app_routes.dart';
import 'package:road_project_flutter/features/home/presentation/models/post_model.dart';
import 'package:road_project_flutter/features/home/presentation/screen/story_screen.dart';
import 'package:road_project_flutter/services/storage/storage_services.dart';
import 'package:road_project_flutter/utils/app_utils.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'package:road_project_flutter/utils/log/app_log.dart';

import '../controller/home_controller.dart';
import '../models/story_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      body: SafeArea(
        child: GetBuilder(
          init: HomeController(),
          builder: (controller) => Column(
            children: [
              // Custom AppBar
              _buildCustomAppBar(
                cartCount: controller.cartCount.value,
                messageCount: controller.messageCount.value,
                notificationCount: controller.notificationCount.value,
              ),

              // Stories Section
              _buildStoriesSection(controller),

              // Posts Section
              // controller.postLoading.value
              //     ? Center(child: CircularProgressIndicator())
              //     : controller.posts.isEmpty
              //     ? Center(
              //         child: Text(
              //           "No Post Found",
              //           style: TextStyle(color: AppColors.white),
              //         ),
              //       )
              //     : Expanded(
              //         child: ListView.builder(
              //           controller: controller.scrollController,
              //           itemCount: controller.posts.length,
              //           itemBuilder: (context, index) {
              //             return PostCard(index: index, controller: controller);
              //           },
              //         ),
              //       ),
              Expanded(
                child: PaginatedListViewBuilder<PostModel>(
                  controller: controller.postPaginatedController,
                  isLoading: controller.postLoading.value,
                  initLoadingWidget: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  onHitThreshold: (context, current) {
                    if (!controller.postLoading.value) {
                      appLog("load post current: $current");
                      controller.loadPosts(context, current);
                    }
                  },
                  endListLoadingWidget: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                  itemBuilder: (context, index, currentData) {
                    return PostCard(index: index, controller: controller);
                  },
                  emptyStateWidget: Center(child: Text("No Post Found")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar({
    required int cartCount,
    required int notificationCount,
    required int messageCount,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.createPost),
                child: Icon(Icons.add, color: Colors.white, size: 26.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                'Road to 1%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.cartScreen);
                },
                child: _buildIconWithBadge(
                  Icons.shopping_cart_outlined,
                  cartCount,
                  AppColors.primaryColor,
                  AppColors.black,
                ),
              ),
              SizedBox(width: 20.w),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.notificationScreen);
                },
                child: _buildIconWithBadge(
                  Icons.notifications_outlined,
                  notificationCount,
                  Colors.red,
                  AppColors.white,
                ),
              ),
              SizedBox(width: 20.w),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.chatScreenImage);
                },
                child: _buildIconWithBadge(
                  Icons.chat,
                  messageCount,
                  AppColors.textColor,
                  AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithBadge(
    IconData icon,
    int count,
    Color color,
    Color textColor,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: Colors.white, size: 24.sp),
        if (count > 0)
          Positioned(
            right: -6.w,
            top: -6.h,
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStoriesSection(HomeController controller) {
    return Container(
      height: 110.h,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          StoryItem(
            story: StoryModel(
              id: "",
              name: "Your Story",
              image: LocalStorage.profileImage,
              storyCount: 0,
              priority: 0,
              isWatched: false,
              connectionStatus: "",
            ),
            isOwn: true,
          ), // need to change later
          // controller.storyLoading.value
          //     ? Center(child: SizedBox.shrink())
          //     : controller.stories.isEmpty
          //     ? SizedBox.shrink()
          //     : Expanded(
          //         child: ListView.builder(
          //           scrollDirection: Axis.horizontal,
          //           itemCount: controller.stories.length,
          //           itemBuilder: (context, index) {
          //             return StoryItem(
          //               story: controller.stories[index],
          //               isOwn: false,
          //             );
          //           },
          //         ),
          //       ),
          Expanded(
            child: PaginatedListViewBuilder(
              controller: controller.storyPaginationController,
              itemBuilder: (context, index, currentData) =>
                  StoryItem(story: currentData, isOwn: false),
              // isLoading: controller.storyLoading.value,
              endListLoadingWidget: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator.adaptive()),
              ),
              scrollDirection: Axis.horizontal,
              onHitThreshold: (context, current) {
                if (!controller.storyLoading.value) {
                  controller.loadStories(context, current);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StoryItem extends StatelessWidget {
  final StoryModel story;
  final bool isOwn;

  const StoryItem({super.key, required this.story, required this.isOwn});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isOwn) {
          // ✅ Navigate to CreateStoryScreen
          Get.to(() => CreateStoryScreen());
        } else {
          Get.toNamed(AppRoutes.storyViewScreen, arguments: story.id);
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 12.w),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 65.w,
                  height: 65.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: !story.isWatched
                          ? AppColors.primaryColor
                          : Colors.grey.shade800,
                      width: 2.5.w,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3.r),
                    child: ClipOval(
                      child: Image.network(
                        ApiEndPoint.imageUrl + story.image,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.network(AppString.defaultProfilePic),
                      ),
                    ),
                  ),
                ),
                if (isOwn)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00ff87),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2.w),
                      ),
                      child: Icon(Icons.add, color: Colors.black, size: 12.sp),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              story.name,
              style: TextStyle(color: Colors.white, fontSize: 11.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final int index;
  final HomeController controller;

  const PostCard({super.key, required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      color: const Color(0xFF0a0a0a),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          _buildPostHeader(context),

          // Post Images
          _buildPostImages(),

          // Post Actions
          _buildPostActions(context),

          // Post Caption
          SizedBox(height: 8.h),
          _buildPostCaption(),

          // Comments Section
          // if (post.commentOfPost != 0) _buildCommentsSection(),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              height: 80,
              width: 80,
              ApiEndPoint.imageUrl + controller.posts[index].creator.image,
              errorBuilder: (context, error, stackTrace) => Image.network(
                AppString.defaultProfilePic,
                height: 70,
                width: 70,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.posts[index].creator.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
                Text(
                  Utils.timeAgo(controller.posts[index].createAt),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => controller.onConnectTap(
              context,
              controller.posts[index].creator.id,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                "Connect",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => controller.onMoreTap(controller.posts[index].id),
            child: Icon(
              Icons.more_vert,
              color: Colors.grey.shade400,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImages() {
    final pageController = controller.getPageController(
      controller.posts[index].id,
    );
    final currentPage = controller.getCurrentPage(controller.posts[index].id);

    // I hide this
    // if (pageController == null || currentPage == null) {
    //   return const SizedBox.shrink();
    // }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 400.h,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (page) =>
                controller.onPageChanged(controller.posts[index].id, page),
            itemCount: controller.posts[index].image.length,
            itemBuilder: (context, imageIndex) {
              return Image.network(
                ApiEndPoint.imageUrl +
                    controller.posts[index].image[imageIndex],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.white),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (controller.posts[index].image.length > 1)
          Positioned(
            bottom: 10.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.posts[index].image.length,
                (dotIndex) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPage!.value == dotIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.toggleLike(controller.posts[index].id),
            child: Icon(
              controller.posts[index].isLiked
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: controller.posts[index].isLiked
                  ? Colors.red
                  : AppColors.primaryColor,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            '${controller.posts[index].likeOfPost}',
            style: TextStyle(color: AppColors.primaryColor, fontSize: 14.sp),
          ),
          SizedBox(width: 20.w),
          GestureDetector(
            onTap: () => controller.onCommentTap(controller.posts[index].id),
            child: Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            '${controller.posts[index].commentOfPost}',
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                controller.onSaveTap(context, controller.posts[index].id),
            child: Icon(
              controller.posts[index].hasSave
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: Colors.white,
              size: 26.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCaption() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              children: [
                TextSpan(
                  text: '${controller.posts[index].creator.name} ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: controller.posts[index].caption),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          // Text(
          //   '#${post.hashtag}',
          //   style: TextStyle(color: const Color(0xFF00a8ff), fontSize: 14.sp),
          // ),
        ],
      ),
    );
  }

  // I keep it hidden
  // Widget _buildCommentsSection() {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         RichText(
  //           text: TextSpan(
  //             style: TextStyle(color: Colors.white, fontSize: 13.sp),
  //             children: [
  //               TextSpan(
  //                 text: '${post.comments[0].userName} ',
  //                 style: const TextStyle(fontWeight: FontWeight.w600),
  //               ),
  //               TextSpan(
  //                 text: post.comments[0].comment,
  //                 style: TextStyle(color: Colors.grey.shade400),
  //               ),
  //             ],
  //           ),
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
