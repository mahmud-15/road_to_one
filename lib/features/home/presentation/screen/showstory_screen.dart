import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/features/home/presentation/controller/show_story_controller.dart';
import 'package:road_project_flutter/utils/app_utils.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';

class StoryViewScreen extends StatefulWidget {
  const StoryViewScreen({super.key});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  final controller = Get.put(ShowStoryController());
  final focusNode = FocusNode();
  final GlobalKey _likeKey = GlobalKey();

  // Static stories data
  // final List<StoryData> stories = [
  //   StoryData(
  //     userName: 'Alaraq_leo',
  //     userImage:
  //         'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
  //     storyImage:
  //         'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
  //     time: '5m ago',
  //     caption:
  //         'Spierenque Praesent Donec Amet. Eget Lorem. Consecteur Id Venus At. Nec Nec Odiam Amet. Tincidunt Quis Vitae In See More...',
  //   ),
  //   StoryData(
  //     userName: 'Alaraq_leo',
  //     userImage:
  //         'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
  //     storyImage:
  //         'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
  //     time: '10m ago',
  //     caption: 'Morning workout session 💪',
  //   ),
  //   StoryData(
  //     userName: 'Alaraq_leo',
  //     userImage:
  //         'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
  //     storyImage:
  //         'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800',
  //     time: '15m ago',
  //     caption: 'Never give up on your dreams! 🔥',
  //   ),
  // ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animationController.addListener(() {
      setState(() {});
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _pauseStory(); // stop when typing
      } else {
        _resumeStory(); // resume when keyboard closes
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < controller.userStory.value!.stories.length - 1) {
      _currentIndex++;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.reset();
      _animationController.forward();
    } else {
      Get.back();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _pauseStory() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
  }

  void _resumeStory() {
    if (!_animationController.isAnimating) {
      _animationController.forward();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      controller.sendMessage(context, _messageController.text.trim());
      setState(() {
        _messages.add(_messageController.text.trim());
        _messageController.clear();
      });
      // I will work on here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: controller.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTapDown: (details) {
                final RenderBox? box =
                    _likeKey.currentContext?.findRenderObject() as RenderBox?;

                if (box != null) {
                  final Offset position = box.localToGlobal(Offset.zero);
                  final Size size = box.size;

                  final Rect likeRect = position & size;

                  if (likeRect.contains(details.globalPosition)) {
                    return; // ⛔ Ignore story navigation
                  }
                }
                final screenWidth = MediaQuery.of(context).size.width;
                final dx = details.globalPosition.dx;

                if (dx < screenWidth / 3) {
                  _previousStory();
                } else if (dx > 2 * screenWidth / 3) {
                  _nextStory();
                }
              },
              onLongPressStart: (_) => _pauseStory(),
              onLongPressEnd: (_) => _resumeStory(),
              child: Stack(
                children: [
                  // Story Images
                  PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.userStory.value?.stories.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        ApiEndPoint.imageUrl +
                            controller.userStory.value!.stories[index].image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.network(
                              AppString.defaultProfilePic,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                      );
                    },
                  ),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Story Progress Bars
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          child: Row(
                            children: List.generate(
                              controller.userStory.value!.stories.length,
                              (index) => Expanded(
                                child: Container(
                                  height: 3.h,
                                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: index == _currentIndex
                                        ? _animationController.value
                                        : index < _currentIndex
                                        ? 1.0
                                        : 0.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          2.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // User Info Header
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20.r,
                                backgroundImage: NetworkImage(
                                  ApiEndPoint.imageUrl +
                                      controller.userStory.value!.user.image,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.userStory.value!.user.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      Utils.timeAgo(
                                        controller
                                            .userStory
                                            .value!
                                            .stories[_currentIndex]
                                            .createAt,
                                      ),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 28.sp,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Messages Display
                        if (_messages.isNotEmpty)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            padding: EdgeInsets.all(12.r),
                            constraints: BoxConstraints(maxHeight: 200.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Messages:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _messages.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 6.h),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF00ff87,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF00ff87,
                                            ).withOpacity(0.5),
                                          ),
                                        ),
                                        child: Text(
                                          _messages[index],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 8.h),

                        // Caption at bottom
                        if (controller
                            .userStory
                            .value!
                            .stories[_currentIndex]
                            .caption
                            .isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.r),
                            margin: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              controller
                                  .userStory
                                  .value!
                                  .stories[_currentIndex]
                                  .caption,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                height: 1.4,
                              ),
                            ),
                          ),

                        // Message Input
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                  child: TextField(
                                    focusNode: focusNode,
                                    controller: _messageController,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                                    onSubmitted: (_) => _sendMessage(),
                                    decoration: InputDecoration(
                                      hintText: 'Type a message',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 14.sp,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: _sendMessage,
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00ff87),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.black,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                key: _likeKey,
                                onTap: () {
                                  controller.toggleStoryLike(_currentIndex);
                                  setState(() {});
                                },
                                child: Icon(
                                  controller
                                          .userStory
                                          .value!
                                          .stories[_currentIndex]
                                          .isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 28.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
