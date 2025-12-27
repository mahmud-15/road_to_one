import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../controller/order_history_controller.dart';
import '../../data/order_model.dart';

class OrderHistoryScreen extends StatelessWidget {
  OrderHistoryScreen({super.key});

  final OrderHistoryController controller = Get.put(OrderHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBarNew(title: "Order History"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFb4ff39),
            ),
          );
        }
        if (controller.orders.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // SizedBox(height: 12.h),
            // _buildHeaderRow(),
            SizedBox(height: 8.h),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                itemCount: controller.orders.length,
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
                  return _buildOrderItem(order);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrderItem(Order order) {
    return InkWell(
      onTap: () => controller.viewOrderDetails(order),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 14.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
        decoration: BoxDecoration(
          color: Color(0xFF1C1C1C),
          border: Border.all(color: Color(0xFF333333)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildCell(
                label: 'Order Id',
                value: order.orderNumber,
                alignEnd: false,
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildCell(
                label: 'Items',
                value: order.itemCount.toString().padLeft(2, '0'),
                alignEnd: false,
              ),
            ),
            Expanded(
              flex: 3,
              child: _buildCell(
                label: 'Price',
                value:
                    '${order.currencySymbol}${order.totalPrice.toStringAsFixed(2)}',
                alignEnd: false,
              ),
            ),
            Expanded(
              flex: 3,
              child: _buildCell(
                label: 'Date',
                value: order.date,
                alignEnd: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Order Id',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Items',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Price',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Date',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell({
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: Colors.grey[700],
            size: 80.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Orders Yet',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your order history will appear here',
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
