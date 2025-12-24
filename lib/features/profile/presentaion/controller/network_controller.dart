import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';

import '../../data/network_status.dart';

class NetworkController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  RxList<NetworkUser> users = <NetworkUser>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchUsers(Get.context!);
  }

  void fetchUsers(BuildContext context) async {
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
  }

  void acceptFollowRequest(int index) {
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

  void rejectFollowRequest(int index) {
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

  void unfollowUser(int index) {
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
