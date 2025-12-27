import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/features/business/presentation/controller/business_controller.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../../../../component/image/app_bar.dart';

class BusinessScreen extends StatefulWidget {
  BusinessScreen({Key? key}) : super(key: key);

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  final BusinessController controller = Get.put(BusinessController());
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) {
        return;
      }

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (currentScroll >= (maxScroll - 200)) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h), // 👈 AppBar height increased
        child: AppBarNew(title: "Personal Business & Mindset Development Plan",showBackButton: false,),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          itemCount: controller.plans.length + (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.plans.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final plan = controller.plans[index];
            return _buildPlanItem(plan);
          },
        );
      }),
    );
  }

  Widget _buildPlanItem(Map<String, dynamic> plan) {
    final isLocked = plan['isLocked'] ?? false;

    return GestureDetector(
      onTap: () {
        controller.onPlanTap(plan);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        decoration: BoxDecoration(
          color: isLocked
              ? AppColors.gray.withOpacity(0.3)
              : AppColors.upcolor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                plan['title'] ?? '',
                style: TextStyle(
                  color: isLocked
                      ? Colors.grey[600]
                      : Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              isLocked ? Icons.lock_outline : Icons.chevron_right,
              color: isLocked
                  ? Colors.grey[600]
                  : Colors.white,
              size: isLocked ? 30.sp : 30.sp,
            ),
          ],
        ),
      ),
    );
  }
}