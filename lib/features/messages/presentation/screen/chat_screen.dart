import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../../../home/presentation/screen/showstory_screen.dart';
import '../../../home/presentation/screen/story_screen.dart';
import '../../data/chat_model.dart';
import '../../data/story_model.dart';
import '../controller/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBarNew(title: "Chat"),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 20.sp,
                ),
                filled: true,
                fillColor: Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),

          // Stories Section
          Container(
            height: 100.h,
            padding: EdgeInsets.only(left: 16.w),
            child: Obx(
              () {
                final showStoryShimmer =
                    controller.storyLoading.value && controller.stories.length <= 1;

                if (showStoryShimmer) {
                  final items = controller.stories;
                  return Row(
                    children: [
                      if (items.isNotEmpty) _buildStoryItem(items.first),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return _buildStoryShimmerItem();
                          },
                        ),
                      ),
                    ],
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.axis != Axis.horizontal) {
                      return false;
                    }

                    final remaining = notification.metrics.maxScrollExtent -
                        notification.metrics.pixels;
                    if (remaining < 120 && controller.storyLoading.value == false) {
                      controller.fetchStories(refresh: false);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.stories.length,
                    itemBuilder: (context, index) {
                      final story = controller.stories[index];
                      return _buildStoryItem(story);
                    },
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 8.h),

          // Chat List
          Expanded(
            child: Obx(
              () {
                final showChatShimmer =
                    controller.isLoading.value && controller.conversations.isEmpty;
                if (showChatShimmer) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return _buildChatShimmerItem();
                    },
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: controller.refreshConversations,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.conversations.length,
                    itemBuilder: (context, index) {
                      controller.loadMoreIfNeeded(index);
                      final chat = controller.conversations[index];
                      return _buildChatItem(chat);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryShimmerItem() {
    return Container(
      margin: EdgeInsets.only(right: 12.w),
      child: Column(
        children: [
          _ShimmerBox(
            width: 64.w,
            height: 64.h,
            borderRadius: 999,
          ),
          SizedBox(height: 6.h),
          _ShimmerBox(
            width: 52.w,
            height: 10.h,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildChatShimmerItem() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          _ShimmerBox(
            width: 56.r,
            height: 56.r,
            borderRadius: 999,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  width: 160.w,
                  height: 12.h,
                  borderRadius: 8,
                ),
                SizedBox(height: 8.h),
                _ShimmerBox(
                  width: 220.w,
                  height: 10.h,
                  borderRadius: 8,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _ShimmerBox(
            width: 32.w,
            height: 10.h,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(Story story) {
    return GestureDetector(
      onTap: () {
        if (story.isYourStory) {
          Get.to(() => CreateStoryScreen());
        } else {
          Get.to(() => const StoryViewScreen(), arguments: story.id);
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        child: Column(
          children: [
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: story.isYourStory
                      ? Colors.grey[600]!
                      : AppColors.primaryColor,
                  width: 2.5,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    width: 65.w,
                    height: 65.h,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: Padding(
                      padding: EdgeInsets.all(3.r),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(story.avatar),
                      ),
                    ),
                  ),
                  if (story.isYourStory)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2.w),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            SizedBox(
              width: 64.w,
              child: Text(
                story.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 11.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(ChatMessage chat) {
    return InkWell(
      onTap: () => controller.onChatTap(chat),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: NetworkImage(chat.avatar),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.upcolor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),

            // Name and Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    chat.message,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Time and Online indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
                ),
                SizedBox(height: 4.h),
                if (chat.isOnline)
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = const Color(0xFF2A2A2A);
    final highlight = Colors.white.withOpacity(0.10);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment(-1.0 - 2.0 * (1.0 - t), 0),
                end: Alignment(1.0 + 2.0 * t, 0),
                colors: [base, highlight, base],
                stops: const [0.35, 0.5, 0.65],
              ).createShader(rect);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              width: widget.width,
              height: widget.height,
              color: base,
            ),
          ),
        );
      },
    );
  }
}
