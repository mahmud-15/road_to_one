import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/services/storage/storage_services.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../../data/message_view.dart';
import '../controller/message_controller.dart';

class MessageScreen extends StatelessWidget {
  final String conversationId;
  final String receiverId;
  final String chatName;
  final String chatAvatar;
  final bool isOnline;

  const MessageScreen({
    super.key,
    required this.conversationId,
    required this.receiverId,
    required this.chatName,
    required this.chatAvatar,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    final MessageController controller = Get.put(
      MessageController(
        conversationId: conversationId,
        receiverId: receiverId,
        chatName: chatName,
        chatAvatar: chatAvatar,
        isOnline: isOnline,
      ),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.upcolor,
        appBar: AppBar(
          backgroundColor: AppColors.upcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: Colors.grey[800],
                backgroundImage: NetworkImage(chatAvatar),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: isOnline ? AppColors.primaryColor : Colors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages List
            Expanded(
              child: Obx(
                () {
                  final showShimmer =
                      controller.isLoading.value && controller.messages.isEmpty;
                  if (showShimmer) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final itemExtent = 74.h;
                        final count = (constraints.maxHeight / itemExtent)
                            .ceil()
                            .clamp(10, 18);
                        return ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.all(16.w),
                          itemCount: count,
                          itemBuilder: (context, index) {
                            return _MessageShimmerBubble(
                              index: index,
                              isMine: index.isEven,
                            );
                          },
                        );
                      },
                    );
                  }

                  final showLoadMore =
                      controller.isLoadingMore.value && controller.messages.isNotEmpty;
                  final itemCount =
                      controller.messages.length + (showLoadMore ? 1 : 0);

                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.axis != Axis.vertical) {
                        return false;
                      }

                      // reverse:true => reaching top loads older messages
                      final remaining = notification.metrics.maxScrollExtent -
                          notification.metrics.pixels;
                      if (remaining < 200 && controller.isLoadingMore.value == false) {
                        controller.fetchMessages(refresh: false);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.all(16.w),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (showLoadMore && index == controller.messages.length) {
                          return const _MessageLoadMoreShimmer();
                        }

                        final message = controller.messages[index];
                        return _buildMessageBubble(message, chatAvatar);
                      },
                    ),
                  );
                },
              ),
            ),

            // Message Input
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.upcolor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Attachment Button
                  GestureDetector(
                    onTap: controller.showImageOptions,
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.attach_file,
                        color: Colors.white70,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Text Input
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        filled: true,
                        fillColor: Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.sendMessage(),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Send Button
                  GestureDetector(
                    onTap: () => controller.sendMessage(),
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send, color: Colors.black, size: 20.sp),
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

  Widget _buildMessageBubble(Message message, String chatAvatar) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: message.isSentByMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for received messages
          if (!message.isSentByMe) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.grey[800],
              backgroundImage: NetworkImage(chatAvatar),
            ),
            SizedBox(width: 8.w),
          ],

          // Message Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: message.isSentByMe
                        ? Color(0xFF7C9631)
                        : Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: message.isSentByMe
                          ? Radius.circular(16.r)
                          : Radius.zero,
                      bottomRight: message.isSentByMe
                          ? Radius.zero
                          : Radius.circular(16.r),
                    ),
                  ),
                  child: message.imageUrl != null && message.imageUrl!.trim().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: _buildMessageImage(message.imageUrl!),
                        )
                      : Text(
                          message.text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            height: 1.4,
                          ),
                        ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11.sp,
                      ),
                    ),
                    if (message.isSentByMe) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.done_all,
                        color: Colors.grey[600],
                        size: 14.sp,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Avatar for sent messages (optional)
          if (message.isSentByMe) SizedBox(width: 8.w),
        ],
      ),
    );
  }

  Widget _buildMessageImage(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return const SizedBox.shrink();

    final secondHttpIndex = v.indexOf('http', 1);
    final fixed = secondHttpIndex != -1 ? v.substring(secondHttpIndex) : v;

    final isRemote = fixed.startsWith('http://') || fixed.startsWith('https://');
    final isRelative = fixed.startsWith('/');
    if (isRemote || isRelative) {
      final url = isRelative ? (ApiEndPoint.imageUrl + fixed) : fixed;
      final needsAuth = url.startsWith(ApiEndPoint.imageUrl);
      return Image.network(
        url,
        width: 200.w,
        fit: BoxFit.cover,
        headers: needsAuth
            ? <String, String>{
                'Authorization': 'Bearer ${LocalStorage.token}',
              }
            : null,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    }

    return Image.file(
      File(fixed),
      width: 200.w,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _MessageShimmerBubble extends StatelessWidget {
  final int index;
  final bool isMine;

  const _MessageShimmerBubble({
    required this.index,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final showImage = index % 6 == 0;
    final w1 = (index % 4 == 0) ? 210.w : 180.w;
    final w2 = (index % 3 == 0) ? 140.w : 120.w;
    final w3 = (index % 5 == 0) ? 90.w : 70.w;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            _ShimmerBox(width: 32.r, height: 32.r, borderRadius: 999),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: w1, height: 12.h, borderRadius: 14),
                SizedBox(height: 8.h),
                _ShimmerBox(width: w2, height: 12.h, borderRadius: 14),
                if (showImage) ...[
                  SizedBox(height: 10.h),
                  _ShimmerBox(width: 180.w, height: 120.h, borderRadius: 16),
                ],
                SizedBox(height: 8.h),
                Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: _ShimmerBox(width: w3, height: 10.h, borderRadius: 10),
                ),
              ],
            ),
          ),
          if (isMine) SizedBox(width: 8.w),
        ],
      ),
    );
  }
}

class _MessageLoadMoreShimmer extends StatelessWidget {
  const _MessageLoadMoreShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Center(
        child: _ShimmerBox(width: 160.w, height: 10.h, borderRadius: 10),
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
