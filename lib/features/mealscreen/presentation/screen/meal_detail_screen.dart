import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../controller/meal_detail_controller.dart';

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MealDetailController controller = Get.put(MealDetailController());
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBarNew(title: "Meal Details"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: const Color(0xFFb4ff39),
            ),
          );
        }

        final meal = controller.mealDetail.value;
        if (meal == null) {
          return const Center(
            child: Text(
              'No meal details available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (meal.imageUrl.isNotEmpty)
              //   Container(
              //     width: double.infinity,
              //     height: 250.h,
              //     margin: EdgeInsets.all(16.w),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(16.r),
              //       image: DecorationImage(
              //         image: NetworkImage(meal.imageUrl),
              //         fit: BoxFit.cover,
              //       ),
              //     ),
              //   ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  meal.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Html(
                  data: meal.description,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      color: Colors.grey[400],
                      fontSize: FontSize(14.sp),
                      lineHeight: const LineHeight(1.5),
                    ),
                  },
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        );
      }),
    );
  }
}