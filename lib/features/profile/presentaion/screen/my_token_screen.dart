import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../controller/my_token_controller.dart';

class MyTokenScreen extends StatelessWidget {
  MyTokenScreen({super.key});

  final MyTokenController controller = Get.put(MyTokenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBarNew(title: 'My Token'),
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CircularProgressIndicator(
              color: Color(0xFFb4ff39),
            );
          }

          final value = controller.tokenCount.value.clamp(0, 1 << 31);
          final text = value.toString().padLeft(2, '0');

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 140.w,
                height: 140.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFD54F),
                ),
                child: Center(
                  child: Container(
                    width: 86.w,
                    height: 86.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF9A825),
                    ),
                    child: Icon(
                      Icons.star,
                      color: const Color(0xFFFFD54F),
                      size: 44.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 26.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: const Color(0xFFF9A825),
                    width: 1,
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: const Color(0xFFFFD54F),
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Tokens left',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
