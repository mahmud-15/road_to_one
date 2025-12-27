import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../../data/order_model.dart';
import '../controller/order_details_controller.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;









  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final orderNo = order.orderNumber.replaceAll('#', '').trim();
    final OrderDetailsController controller = Get.put(
      OrderDetailsController(orderNo: orderNo),
      tag: orderNo,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBarNew(title: 'Order Details'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFb4ff39),
            ),
          );
        }

        final items = controller.items;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 14.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  border: Border.all(color: const Color(0xFF333333)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildMeta(
                        label: 'Order Id',
                        value: order.orderNumber,
                        alignEnd: false,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildMeta(
                        label: 'Items',
                        value: order.itemCount.toString().padLeft(2, '0'),
                        alignEnd: false,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildMeta(
                        label: 'Price',
                        value:
                            '${order.currencySymbol}${order.totalPrice.toStringAsFixed(2)}',
                        alignEnd: false,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildMeta(
                        label: 'Date',
                        value: order.date,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              if (items.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Text(
                    'No order items available',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14.w),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF333333)),
                    color: Colors.white.withOpacity(.12),
                  ),
                  child: Column(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            color: Colors.black,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: Image.network(
                                    item.image,
                                    width: 54.w,
                                    height: 54.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 54.w,
                                      height: 54.w,
                                      color: Colors.white.withOpacity(0.08),
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.white.withOpacity(0.4),
                                        size: 22.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'x${item.quantity}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.65),
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${order.currencySymbol}${item.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (index != items.length - 1)
                            Container(
                              height: 10.h,
                              color: Colors.white.withOpacity(0.06),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMeta({
    required String label,
    required String value,
    required bool alignEnd,
  }) {
    final align = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
