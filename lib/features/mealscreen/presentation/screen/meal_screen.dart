import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../../../../config/route/app_routes.dart';
import '../controller/meal_category_controller.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MealCategoryController controller = Get.put(MealCategoryController());
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBarNew(title: "Meal Prep Recipes"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFb4ff39),
              ),
            );
          }

          if (controller.categories.isEmpty) {
            return const Center(
              child: Text(
                'No categories found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.detailFoodScreen,
                    arguments: {
                      'id': category.id,
                      'title': category.title,
                    },
                  );
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: AppColors.upcolor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
