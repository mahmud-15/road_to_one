import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';
import 'package:road_project_flutter/utils/constants/app_icons.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';

import '../../data/network_status.dart';
import '../controller/network_controller.dart';

class NetworkScreen extends StatelessWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBarNew(title: "Network"),
      body: GetBuilder(
        init: NetworkController(),
        builder: (controller) => Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: TextField(
                  controller: controller.searchController,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 20.sp,
                    ),
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ),
            ),

            // Users List
            Expanded(
              child: controller.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : controller.users.isEmpty
                  ? Center(
                      child: Text(
                        "No network found",
                        style: TextStyle(color: AppColors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: controller.users.length,
                      itemBuilder: (context, index) {
                        return _buildNetworkItem(context, controller, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkItem(
    BuildContext context,
    NetworkController controller,
    int index,
  ) {
    final user = controller.users[index];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 24.r,
            backgroundColor: Colors.grey[800],
            child: ClipOval(
              child: Image.network(
                fit: BoxFit.cover,
                width: 48.r,
                height: 48.r,
                ApiEndPoint.imageUrl + user.user.image,
                errorBuilder: (context, error, stackTrace) => Image.network(
                  AppString.defaultProfilePic,
                  width: 48.r,
                  height: 48.r,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.user.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
                ),
              ],
            ),
          ),

          // Action Buttons based on status
          Obx(() => _buildActionButtons(context, controller, index)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    NetworkController controller,
    int index,
  ) {
    final user = controller.users[index];
    switch (user.status) {
      case "pending":
        return Row(
          children: [
            // Follow Back Button
            ElevatedButton(
              onPressed: () => controller.acceptFollowRequest(context, index),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFb4ff39),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                minimumSize: Size(0, 0),
              ),
              child: Text(
                'Accept',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            ElevatedButton(
              onPressed: () => controller.rejectFollowRequest(context, index),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                minimumSize: Size(0, 0),
              ),
              child: Text(
                'Decline',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Close/Reject Button
            // GestureDetector(
            //   onTap: () => controller.rejectFollowRequest(context, index),
            //   child: Icon(Icons.close, color: Colors.white, size: 24.sp),
            // ),
          ],
        );

      case "accepted":
        return Row(
          children: [
            // Message Button
            ElevatedButton(
              onPressed: () => controller.openMessage(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                minimumSize: Size(0, 0),
              ),
              child: Text(
                'Message',
                style: TextStyle(
                  color: Color(0xFFb4ff39),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => controller.unfollowUser(context, index),
              child: Image.asset(AppIcons.removeUser),
            ),
            // More Options
            // GestureDetector(
            //   onTap: () => _showFollowingOptions(controller, index),
            //   child: Icon(
            //     Icons.more_vert,
            //     color: Colors.grey[400],
            //     size: 24.sp,
            //   ),
            // ),
          ],
        );

      // case NetworkStatus.accepted:
      //   return Row(
      //     children: [
      //       // Message Button with Icon
      //       ElevatedButton.icon(
      //         onPressed: () => controller.openMessage(user),
      //         icon: Icon(
      //           Icons.chat_bubble_outline,
      //           color: Colors.white,
      //           size: 16.sp,
      //         ),
      //         label: Text(
      //           'Message',
      //           style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 12.sp,
      //             fontWeight: FontWeight.w500,
      //           ),
      //         ),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.grey[800],
      //           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(20.r),
      //           ),
      //           minimumSize: Size(0, 0),
      //         ),
      //       ),
      //       SizedBox(width: 8.w),
      //       // More Options
      //       GestureDetector(
      //         onTap: () => _showConnectedOptions(controller, index),
      //         child: Icon(
      //           Icons.more_vert,
      //           color: Colors.grey[400],
      //           size: 24.sp,
      //         ),
      //       ),
      //     ],
      //   );

      default:
        return SizedBox.shrink();
    }
  }

  // void _showFollowingOptions(NetworkController controller, int index) {
  //   final user = controller.users[index];
  //   Get.bottomSheet(
  //     Container(
  //       padding: EdgeInsets.all(20.r),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFF2d2d2d),
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: Icon(Icons.person_remove, color: Colors.red),
  //             title: Text(
  //               'Unfollow ${user.user.name}',
  //               style: TextStyle(color: Colors.white, fontSize: 16.sp),
  //             ),
  //             onTap: () {
  //               controller.unfollowUser(index);
  //               Get.back();
  //             },
  //           ),
  //           ListTile(
  //             leading: Icon(Icons.block, color: Colors.red),
  //             title: Text(
  //               'Block',
  //               style: TextStyle(color: Colors.white, fontSize: 16.sp),
  //             ),
  //             onTap: () {
  //               controller.blockUser(index);
  //               Get.back();
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showConnectedOptions(NetworkController controller, int index) {
  //   final user = controller.users[index];
  //   Get.bottomSheet(
  //     Container(
  //       padding: EdgeInsets.all(20.r),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFF2d2d2d),
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: Icon(Icons.person_remove, color: Colors.red),
  //             title: Text(
  //               'Unfollow ${user.user.name}',
  //               style: TextStyle(color: Colors.white, fontSize: 16.sp),
  //             ),
  //             onTap: () {
  //               controller.unfollowUser(index);
  //               Get.back();
  //             },
  //           ),
  //           ListTile(
  //             leading: Icon(Icons.notifications_off, color: Colors.white),
  //             title: Text(
  //               'Mute',
  //               style: TextStyle(color: Colors.white, fontSize: 16.sp),
  //             ),
  //             onTap: () {
  //               Get.back();
  //               Get.snackbar(
  //                 'Muted',
  //                 'You muted ${user.user.name}',
  //                 backgroundColor: Colors.grey[800],
  //                 colorText: Colors.white,
  //               );
  //             },
  //           ),
  //           ListTile(
  //             leading: Icon(Icons.block, color: Colors.red),
  //             title: Text(
  //               'Block',
  //               style: TextStyle(color: Colors.white, fontSize: 16.sp),
  //             ),
  //             onTap: () {
  //               controller.blockUser(index);
  //               Get.back();
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
