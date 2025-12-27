// Path: lib/screens/store/shipping_information_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/button/common_button.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../controller/shipping_information_controller.dart';

class ShippingInformationScreen extends StatelessWidget {
  ShippingInformationScreen({Key? key}) : super(key: key);

  final ShippingInformationController controller = Get.put(ShippingInformationController());

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBarNew(
          title: "Shipping Information"
      ),
      body: SafeArea(
        child: Column(
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
                        value: controller.selectedCountry.value,
                        dropdownColor: const Color(0xFF2A2A2A),
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Colors.white.withOpacity(0.8)),
                        decoration: _inputDecoration(hint: 'Select country'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                        items: controller.countries
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
                      decoration: _inputDecoration(hint: 'Enter your address'),
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
                      decoration: _inputDecoration(hint: 'Enter your phone number'),
                    ),

                    SizedBox(height: 24.h),

                    // City + Post Code
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
                                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                decoration: _inputDecoration(hint: 'Enter your city'),
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
                                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(hint: 'Enter post code'),
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
        
            // Payment Amount Section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Amount',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Obx(() => Text(
                        '\$${controller.totalAmount.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Obx(() {
                    final saving = controller.isSaving.value;
                    final processing = controller.isProcessing.value;
                    final busy = saving || processing;
                    return AbsorbPointer(
                      absorbing: busy,
                      child: CommonButton(
                        titleText: processing
                            ? "Processing..."
                            : (saving ? "Saving..." : "Process to Pay"),
                        onTap: () {
                          controller.proceedToPay();
                        },
                      ),
                    );
                  })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
