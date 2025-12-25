import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'package:road_project_flutter/utils/log/error_log.dart';

import '../../data/network_status.dart';

class NetworkController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  RxList<NetworkUser> users = <NetworkUser>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchUsers(Get.context!);
  }

  void fetchUsers(BuildContext context) async {
    isLoading.value = true;
    update();
    try {
      final response = await ApiService2.get(ApiEndPoint.networkedUser);
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
              .map((e) => NetworkUser.fromJson(e))
              .toList();
          users.value = userData;
          update();
        }
      }
    } catch (e) {
      errorLog("error in user network: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void acceptFollowRequest(BuildContext context, int index) async {
    try {
      final body = {"status": "accepted"};
      final url = "${ApiEndPoint.networkedUser}/${users[index].id}";
      final response = await ApiService2.patch(url, body: body);
      if (response != null && response.statusCode == 200) {
        users[index].status = "accepted";
        update();
      }
    } catch (e) {
      errorLog("error in accept follow request: $e");
    }
    // users[index].status = NetworkStatus.accepted;
    // users.refresh();
    // Get.snackbar(
    //   'Success',
    //   'You are now following ${users[index].name}',
    //   backgroundColor: const Color(0xFFb4ff39),
    //   colorText: Colors.black,
    //   duration: const Duration(seconds: 2),
    // );
  }

  void rejectFollowRequest(BuildContext context, int index) async {
    try {
      final body = {"status": "rejected"};
      final url = "${ApiEndPoint.networkedUser}/${users[index].id}";
      final response = await ApiService2.patch(url, body: body);
      if (response != null && response.statusCode == 200) {
        users.removeAt(index);
        update();
      }
    } catch (e) {
      errorLog("error in reject follow request: $e");
    }
    // final userName = users[index].name;
    // users.removeAt(index);
    // Get.snackbar(
    //   'Rejected',
    //   'Follow request from $userName rejected',
    //   backgroundColor: Colors.grey[800],
    //   colorText: Colors.white,
    //   duration: const Duration(seconds: 2),
    // );
  }

  void unfollowUser(BuildContext context, int index) async {
    try {
      final url =
          "${ApiEndPoint.networkedUser}/disconnect/${users[index].user.id}";
      final response = await ApiService2.patch(url);
      if (response != null && response.statusCode == 200) {
        users.removeAt(index);
        update();
      }
    } catch (e) {
      errorLog("error in unfollow: $e");
    }

    // final userName = users[index].name;

    // users.removeAt(index);
    // Get.snackbar(
    //   'Unfollowed',
    //   'You unfollowed $userName',
    //   backgroundColor: Colors.grey[800],
    //   colorText: Colors.white,
    //   duration: const Duration(seconds: 2),
    // );
  }

  void blockUser(int index) {
    // final userName = users[index].name;
    // users.removeAt(index);
    // Get.snackbar(
    //   'Blocked',
    //   'You blocked $userName',
    //   backgroundColor: Colors.red,
    //   colorText: Colors.white,
    //   duration: const Duration(seconds: 2),
    // );
  }

  void openMessage(NetworkUser user) {
    // Get.snackbar(
    //   'Opening Chat',
    //   'Opening message with ${user.name}',
    //   backgroundColor: const Color(0xFFb4ff39),
    //   colorText: Colors.black,
    //   duration: const Duration(seconds: 2),
    // );
    // Navigate to chat screen
    // Get.to(() => ChatScreen(user: user));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
