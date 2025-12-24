// Path: lib/screens/store/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/button/common_button.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/config/route/app_routes.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../controller/product_detail_api_controller.dart';
import '../controller/cart_controller.dart';
import '../../data/models/cart_item.dart';

class ProductDetailScreen extends StatelessWidget {
  ProductDetailScreen({Key? key}) : super(key: key);

  final ProductDetailApiController controller =
      Get.put(ProductDetailApiController());
  final CartController cartController =
      Get.isRegistered<CartController>() ? Get.find<CartController>() : Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBarNew(title: "Product Details"),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFb4ff39),
              ),
            );
          }

          final detail = controller.detail.value;
          if (detail == null) {
            return const Center(
              child: Text(
                'No product details available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final variant = controller.selectedVariant;
          final priceText = (variant?.price.amount.isNotEmpty == true)
              ? '${variant!.price.amount} ${variant.price.currencyCode}'
              : '';

          final selectedColor = controller.selectedColor.value.trim();
          final selectedSize = controller.selectedSize.value.trim();
          final priceAmount = double.tryParse(variant?.price.amount ?? '') ?? 0.0;
          final currencyCode = variant?.price.currencyCode ?? '';
          final productId = detail.id;
          final cartKey = '$productId|$selectedColor|$selectedSize';

          final colorOpt = detail.options.firstWhereOrNull(
            (o) => o.name.toLowerCase() == 'color',
          );
          final sizeOpt = detail.options.firstWhereOrNull(
            (o) => o.name.toLowerCase() == 'size',
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Images (Swipe)
                      Container(
                        width: double.infinity,
                        height: 400.h,
                        margin: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: detail.images.isEmpty
                                  ? Center(
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey[400],
                                        size: 80.sp,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(20.r),
                                      child: PageView.builder(
                                        itemCount: detail.images.length,
                                        itemBuilder: (context, index) {
                                          final img = detail.images[index];
                                          return Image.network(
                                            img.url,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.image,
                                                  color: Colors.grey[400],
                                                  size: 80.sp,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                            ),


                            // Positioned(
                            //   top: 12.h,
                            //   right: 12.w,
                            //   child: Obx(
                            //     () => GestureDetector(
                            //       onTap: controller.toggleFavorite,
                            //       child: Container(
                            //         padding: EdgeInsets.all(8.w),
                            //         decoration: BoxDecoration(
                            //           color: Colors.white.withOpacity(0.9),
                            //           shape: BoxShape.circle,
                            //         ),
                            //         child: Icon(
                            //           controller.isFavorite.value
                            //               ? Icons.favorite
                            //               : Icons.favorite_border,
                            //           color: controller.isFavorite.value
                            //               ? Colors.red
                            //               : Colors.grey[800],
                            //           size: 20.sp,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          
                          
                          
                          ],
                        ),
                      ),
 
                      // Product Info
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name and Price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    detail.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  priceText.isEmpty ? '-' : priceText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            // Text(
                            //   'Item',
                            //   style: TextStyle(
                            //     color: Colors.grey[500],
                            //     fontSize: 14.sp,
                            //   ),
                            // ),
                            SizedBox(height: 6.h),
                            Obx(
                              () => Text(
                                controller.selectedColor.value.isEmpty
                                    ? '-'
                                    : controller.selectedColor.value,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // Size
                            Obx(
                              () => Text(
                                'Size: ${controller.selectedSize.value}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            if (sizeOpt != null && sizeOpt.values.isNotEmpty)
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: sizeOpt.values.map((size) {
                                  return Obx(() {
                                    final isSelected =
                                        controller.selectedSize.value == size;
                                    return GestureDetector(
                                      onTap: () => controller.setSize(size),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.w, vertical: 8.h),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF2A2A2A),
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[700]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          size,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                                }).toList(),
                              )
                            else
                              Text(
                                '-',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14.sp,
                                ),
                              ),

                            SizedBox(height: 24.h),

                            // Color
                            Obx(
                              () => Text(
                                'Color: ${controller.selectedColor.value}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            if (colorOpt != null && colorOpt.values.isNotEmpty)
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: colorOpt.values.map((color) {
                                  return Obx(() {
                                    final isSelected =
                                        controller.selectedColor.value == color;
                                    return GestureDetector(
                                      onTap: () => controller.setColor(color),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14.w, vertical: 8.h),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF2A2A2A),
                                          borderRadius:
                                              BorderRadius.circular(18.r),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[700]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          color,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                                }).toList(),
                              )
                            else
                              Text(
                                '-',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14.sp,
                                ),
                              ),

                            SizedBox(height: 24.h),

                            // Product Description
                            Text(
                              'Product Description',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Colors.grey[700]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                detail.description,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14.sp,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            SizedBox(height: 24.h),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  Obx(() {
                                    final _ = cartController.cartItems.length;
                                    final inCart = cartController.cartItems
                                        .any((e) => e.keyId == cartKey);
                                    return CommonButton(
                                      titleText:
                                          inCart ? "Remove from Cart" : "Add to Cart",
                                      buttonColor: AppColors.transparent,
                                      titleColor: AppColors.white,
                                      borderColor: AppColors.white,
                                      onTap: () async {
                                        if (inCart) {
                                          await cartController.removeItem(cartKey);
                                          return;
                                        }
                                        final imageUrl = detail.images.isNotEmpty
                                            ? detail.images.first.url
                                            : '';
                                        await cartController.addOrIncrement(
                                          CartItem(
                                            keyId: cartKey,
                                            productId: productId,
                                            name: detail.title,
                                            image: imageUrl,
                                            color: selectedColor,
                                            size: selectedSize,
                                            currencyCode: currencyCode,
                                            price: priceAmount,
                                            quantity: 1,
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                  SizedBox(height: 18.h),
                                  CommonButton(
                                    titleText: "Buy with Shop",
                                    onTap: () {
                                      Get.toNamed(AppRoutes.homeNav);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}