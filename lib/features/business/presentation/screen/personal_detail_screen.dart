import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/text/common_text.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../controller/business_plan_detail_controller.dart';

import '../../../../component/image/app_bar.dart';

class PersonalDetailScreen extends StatelessWidget {
  const PersonalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BusinessPlanDetailController controller = Get.put(BusinessPlanDetailController());
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: Obx(() {
          final title = controller.planDetail.value?.title ?? '';
          return AppBarNew(title: title.isEmpty ? "Personal Details" : title);
        }),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final plan = controller.planDetail.value;
        if (plan == null) {
          return const Center(
            child: Text(
              'No details available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Column(
          children: [
            SizedBox(height: 20.h),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CommonText(
                text: plan.description,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
                textAlign: TextAlign.left,
                maxLines: 200,
              ),
            )
          ],
        );
      }),
    );
  }
}
