import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'package:road_project_flutter/utils/log/error_log.dart';

import '../models/notification_model.dart';
import 'home_controller.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _markAllAsRead();
    _loadNotifications(Get.context!);
  }

  Future<void> _markAllAsRead() async {
    try {
      await ApiService2.get(ApiEndPoint.notificationUpdate);
    } catch (_) {
      // ignore
    } finally {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchNotificationCount();
      }
    }
  }

  void _loadNotifications(BuildContext context) async {
    isLoading.value = true;
    update();
    try {
      final response = await ApiService2.get(ApiEndPoint.notifications);
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
            final userData = temp
                .map((e) => NotificationItem.fromJson(e))
                .toList();
            notifications.value = userData;
            update();
          }
        }
      }
    } catch (e) {
      errorLog("error in notification: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Map<String, List<NotificationItem>> get groupedNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    Map<String, List<NotificationItem>> grouped = {
      'Recent': [],
      'Yesterday': [],
    };

    for (var notification in notifications) {
      final notificationDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (notificationDate == today) {
        grouped['Recent']!.add(notification);
      } else if (notificationDate == yesterday) {
        grouped['Yesterday']!.add(notification);
      }
    }

    return grouped;
  }

  void onNotificationTap(NotificationItem notification) async {
    final url = "${ApiEndPoint.notifications}/${notification.id}";
    await ApiService.patch(url);
  }

  void clearAllNotifications() {
    Get.defaultDialog(
      title: 'Clear All',
      titleStyle: TextStyle(color: Colors.white),
      middleText: 'Are you sure you want to clear all notifications?',
      middleTextStyle: TextStyle(color: Colors.white70),
      backgroundColor: Color(0xFF2A2A2A),
      radius: 12,
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.black,
      cancelTextColor: Colors.white,
      buttonColor: Color(0xFFCCFF00),
      onConfirm: () {
        notifications.clear();
        Get.back();
      },
    );
  }
}
