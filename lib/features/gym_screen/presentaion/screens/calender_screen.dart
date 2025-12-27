import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/component/button/common_button.dart';

import '../../data/model/calender_model.dart';
import '../controller/calender_controller.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarController>(
      init: CalendarController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFF1a1a1a),
          appBar: AppBarNew(title: "Calender",),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'My week',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                _buildFilterButtons(controller),
                SizedBox(height: 16.h),
                _buildCalendar(controller),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'My Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                _buildTaskSchedule(controller),
                SizedBox(height: 100.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CommonButton(
                    titleText: 'Save',
                    buttonColor: const Color(0xFFb4ff39),
                    titleColor: Colors.black,
                    isLoading: controller.isTaskSaving,
                    onTap: controller.activeTaskDay?.active == true
                        ? controller.saveTaskCalendar
                        : null,
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterButtons(CalendarController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildDropdownButton(controller.selectedYear.toString(), () {
            Get.back();
            controller.showYearPicker();
          }),
          SizedBox(width: 8.w),
          _buildDropdownButton(controller.selectedMonth, () {
            controller.showMonthPicker();
          }),
          SizedBox(width: 8.w),
          _buildDateRangeButton(controller.dateRange),
        ],
      ),
    );
  }

  Widget _buildDropdownButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2d2d2d),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCalendar(CalendarController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
              return SizedBox(
                width: 32.w,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),
          // Calendar grid (drag to select)
          LayoutBuilder(
            builder: (context, constraints) {
              final days = controller.calendarWeeks.expand((w) => w).toList();

              final cellSize = 32.w;
              final columns = 7;

              final crossSpacing =
                  ((constraints.maxWidth - (columns * cellSize)) / (columns - 1))
                      .clamp(0.0, double.infinity);
              final mainSpacing = 8.h;

              int? indexFromOffset(Offset localPosition) {
                final strideX = cellSize + crossSpacing;
                final strideY = cellSize + mainSpacing;

                final col = (localPosition.dx / strideX).floor();
                final row = (localPosition.dy / strideY).floor();

                if (col < 0 || col >= columns || row < 0) return null;
                final index = row * columns + col;
                if (index < 0 || index >= days.length) return null;
                return index;
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  final index = indexFromOffset(details.localPosition);
                  if (index == null) return;
                  controller.startDragSelection(days[index].date);
                },
                onPanUpdate: (details) {
                  final index = indexFromOffset(details.localPosition);
                  if (index == null) return;
                  controller.updateDragSelection(days[index].date);
                },
                onPanEnd: (_) => controller.endDragSelection(),
                onPanCancel: controller.endDragSelection,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: cellSize,
                    crossAxisSpacing: crossSpacing,
                    mainAxisSpacing: mainSpacing,
                  ),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    return _buildCalendarDay(
                      days[index],
                      controller,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(
    CalendarDay day,
    CalendarController controller,
  ) {
    final isSelected = controller.isDateSelected(day.date);
    final activeDate = controller.activeDate;
    final normalized = DateTime(day.date.year, day.date.month, day.date.day);
    final isActive = activeDate != null &&
        activeDate.year == normalized.year &&
        activeDate.month == normalized.month &&
        activeDate.day == normalized.day;
    final isToday = controller.isToday(day.date);

    Color textColor = Colors.white;
    if (!day.isCurrentMonth) {
      textColor = Colors.grey[700]!;
    }

    final selectedColor = const Color(0xFF4a5a3a);
    final activeColor = const Color(0xFFb4ff39);

    final shouldShowSelectedCircle = isSelected || isActive;
    final circleColor = isActive ? activeColor : selectedColor;
    if (isActive) {
      textColor = Colors.black;
    }

    return GestureDetector(
      onTap: () => controller.selectDate(day.date),
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (shouldShowSelectedCircle)
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              day.day.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: 14.sp,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSchedule(CalendarController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: controller.isTaskLoading
          ? SizedBox(
              height: 80.h,
              child: Center(
                child: SizedBox(
                  height: 22.w,
                  width: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFb4ff39),
                  ),
                ),
              ),
            )
          : Row(
              children: controller.taskDays.map((dayData) {
                final isActive = dayData.active;
                final onTap = isActive
                    ? controller.toggleActiveTaskSelection
                    : null;
                return Expanded(
                  child: _buildDayTask(
                    isActive ? 'Today' : dayData.day,
                    dayData.work,
                    dayData.selected,
                    isActive,
                    onTap,
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildDayTask(
    String day,
    String task,
    bool isChecked,
    bool isActive,
    VoidCallback? onTap,
  ) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: isActive ? const Color(0xFFb4ff39) : Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              border: Border.all(
                color: (isChecked || isActive)
                    ? const Color(0xFFb4ff39)
                    : Colors.grey[700]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: isChecked
                ? Icon(
              Icons.check,
              color: const Color(0xFFb4ff39),
              size: 20.sp,
            )
                : null,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          task,
          style: TextStyle(
            color:isActive ? const Color(0xFFb4ff39) : Colors.grey[400],
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}