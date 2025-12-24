import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/utils/app_utils.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../controller/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.upcolor,
      appBar: AppBarNew(title: "Notification"),
      body: GetBuilder(
        init: NotificationController(),
        builder: (controller) {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          // return ListView.builder(
          //   itemCount: controller.notifications.length,
          //   itemBuilder: (context, index) => _buildNotificationItem(
          //     controller,
          //     controller.notifications[index],
          //   ),
          // );
          if (controller.notifications.isEmpty ||
              (controller.groupedNotifications['Yesterday']!.isEmpty &&
                  controller.groupedNotifications['Recent']!.isEmpty)) {
            return _buildEmptyState();
          }

          final grouped = controller.groupedNotifications;

          return ListView(
            children: [
              // Recent Section
              if (grouped['Recent']!.isNotEmpty) ...[
                _buildSectionHeader('Recent'),
                ...grouped['Recent']!.map(
                  (notification) =>
                      _buildNotificationItem(controller, notification),
                ),
              ],

              // Yesterday Section
              if (grouped['Yesterday']!.isNotEmpty) ...[
                _buildSectionHeader('Yesterday'),
                ...grouped['Yesterday']!.map(
                  (notification) =>
                      _buildNotificationItem(controller, notification),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationController controller,
    NotificationItem notification,
  ) {
    return InkWell(
      onTap: () => controller.onNotificationTap(notification),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.message,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              Utils.timeAgo(notification.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, color: Colors.grey[700], size: 80.sp),
          SizedBox(height: 16.h),
          Text(
            'No Notifications',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You don\'t have any notifications yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
