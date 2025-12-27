// Path: lib/screens/store/shipping_information_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/button/common_button.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/features/profile/presentaion/controller/shipping_information_update.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

class ShippingInformationUpdateScreen extends StatelessWidget {
  ShippingInformationUpdateScreen({super.key});

  final ShippingInformationUpdateController controller = Get.put(
    ShippingInformationUpdateController(),
  );

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[600],
        fontSize: 14.sp,
      ),
      filled: true,
      fillColor: const Color(0xFF1C1C1C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22.r),
        borderSide: BorderSide(color: const Color(0xFF333333), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22.r),
        borderSide: const BorderSide(color: Color(0xFF333333), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22.r),
        borderSide: const BorderSide(color: Color(0xFFb4ff39), width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
    );
  }

  void _safeSnackbar(
    String title,
    String message, {
    required Color backgroundColor,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = Get.key.currentContext ?? Get.context;
      if (context == null) {
        return;
      }

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }

      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('$title: $message'),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 2),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBarNew(title: "Shipping Information"),
      body: SafeArea(
        child: Obx(
          () {
            if (controller.isLoadingProfile.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFb4ff39),
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Shipping to
                    Text(
                      'Shipping to',
                      style: TextStyle(
                        color: AppColors.white50,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Country
                    Text(
                      'Country',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: (() {
                          final uniqueItems = controller.countries.toSet();
                          final v = controller.selectedCountry.value.trim();
                          if (v.isEmpty) return null;
                          return uniqueItems.contains(v) ? v : null;
                        })(),
                        dropdownColor: const Color(0xFF1C1C1C),
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Colors.white.withOpacity(0.8)),
                        decoration: _inputDecoration(hint: 'Select country'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                        items: controller.countries
                            .toSet()
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c,
                                child: Text(c),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (v) {
                          if (v == null) return;
                          controller.selectedCountry.value = v;
                        },
                      ),
                    ),

                    // Address Input
                    Text(
                      'Address',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: controller.addressController,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'Enter your address',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1C1C1C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22.r),
                          borderSide:
                              const BorderSide(color: Color(0xFF333333)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22.r),
                          borderSide:
                              const BorderSide(color: Color(0xFF333333)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22.r),
                          borderSide:
                              const BorderSide(color: Color(0xFFb4ff39)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                      maxLines: 2,
                    ),

                    SizedBox(height: 24.h),

                    // Contact Input
                    Text(
                      'Contact',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: controller.contactController,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Enter your phone number',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1C1C1C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22.r),
                          borderSide:
                              const BorderSide(color: Color(0xFF333333)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22.r),
                          borderSide:
                              const BorderSide(color: Color(0xFF333333)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22.r),
                          borderSide:
                              const BorderSide(color: Color(0xFFb4ff39)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // City & Post Code
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'City',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: controller.cityController,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.sp),
                                decoration: _inputDecoration(hint: 'City'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Post Code',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: controller.postCodeController,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.sp),
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(hint: 'Post Code'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Obx(
                    () => CommonButton(
                      titleText: controller.isSaving.value
                          ? "Updating..."
                          : "Update Information",
                      onTap: controller.isSaving.value
                          ? () {}
                          : () async {
                              final ok = await controller.updateShippingInfo();
                              if (ok) {
                                _safeSnackbar(
                                  'Successfully Update',
                                  'Change Your Information',
                                  backgroundColor: const Color(0xff000000),
                                );
                              } else {
                                _safeSnackbar(
                                  'Failed',
                                  'Could not update shipping information.',
                                  backgroundColor: Colors.red,
                                );
                              }
                            },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
