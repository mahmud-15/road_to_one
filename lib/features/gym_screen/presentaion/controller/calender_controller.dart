import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/model/task_calendar_model.dart';
import '../../data/model/calender_model.dart';

class CalendarController extends GetxController {
  int selectedYear = DateTime.now().year;
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  DateTime? activeDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  bool _isDragging = false;

  bool isTaskLoading = false;
  bool isTaskSaving = false;
  List<TaskCalendarDay> taskDays = [];

  @override
  void onInit() {
    super.onInit();
    // Initialize with today's date selected
    final today = _normalizeDate(DateTime.now());
    _rangeStart = today;
    _rangeEnd = today;
    activeDate = today;

    fetchTaskCalendar();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isBeforeToday(DateTime date) {
    final today = _normalizeDate(DateTime.now());
    final normalized = _normalizeDate(date);
    return normalized.isBefore(today);
  }

  DateTime? get rangeStart => _rangeStart;
  DateTime? get rangeEnd => _rangeEnd;

  List<DateTime> get selectedDates {
    if (_rangeStart == null || _rangeEnd == null) return const [];
    final start = _rangeStart!.isBefore(_rangeEnd!) ? _rangeStart! : _rangeEnd!;
    final end = _rangeStart!.isBefore(_rangeEnd!) ? _rangeEnd! : _rangeStart!;

    final dates = <DateTime>[];
    DateTime current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  bool isDateInRange(DateTime date) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    final normalized = _normalizeDate(date);
    final start = _rangeStart!.isBefore(_rangeEnd!) ? _rangeStart! : _rangeEnd!;
    final end = _rangeStart!.isBefore(_rangeEnd!) ? _rangeEnd! : _rangeStart!;
    return (normalized.isAfter(start.subtract(const Duration(days: 1))) &&
        normalized.isBefore(end.add(const Duration(days: 1))));
  }

  String get dateRange {
    final list = selectedDates;
    if (list.isEmpty) return '';
    final start = list.first;
    final end = list.last;
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return '${start.day}th';
    }
    return '${start.day}th - ${end.day}th';
  }

  List<List<CalendarDay>> get calendarWeeks {
    final firstDayOfMonth = DateTime(selectedYear, _getMonthNumber(), 1);

    // Find the first day to display (may be from previous month)
    int firstWeekday = firstDayOfMonth.weekday % 7;
    DateTime startOfCalendar = firstDayOfMonth.subtract(Duration(days: firstWeekday));

    List<List<CalendarDay>> weeks = [];
    DateTime current = startOfCalendar;

    // Generate 5-6 weeks
    for (int week = 0; week < 6; week++) {
      List<CalendarDay> weekDays = [];
      for (int day = 0; day < 7; day++) {
        weekDays.add(CalendarDay(
          day: current.day,
          date: current,
          isCurrentMonth: current.month == firstDayOfMonth.month,
        ));
        current = current.add(const Duration(days: 1));
      }
      weeks.add(weekDays);

      // Stop if we've gone past the current month
      if (current.month != firstDayOfMonth.month && week >= 4) break;
    }

    return weeks;
  }

  int _getMonthNumber() {
    const months = {
      'January': 1, 'February': 2, 'March': 3, 'April': 4,
      'May': 5, 'June': 6, 'July': 7, 'August': 8,
      'September': 9, 'October': 10, 'November': 11, 'December': 12,
    };
    return months[selectedMonth] ?? 1;
  }

  TaskCalendarDay? get activeTaskDay {
    for (final d in taskDays) {
      if (d.active) return d;
    }
    return null;
  }

  void toggleActiveTaskSelection() {
    final active = activeTaskDay;
    if (active == null) return;
    active.selected = !active.selected;
    update();
  }

  Future<void> saveTaskCalendar() async {
    if (isTaskSaving) return;
    if (_rangeStart == null || _rangeEnd == null) return;

    final active = activeTaskDay;
    if (active == null) return;

    isTaskSaving = true;
    update();

    try {
      final start = _rangeStart!.isBefore(_rangeEnd!) ? _rangeStart! : _rangeEnd!;
      final end = _rangeStart!.isBefore(_rangeEnd!) ? _rangeEnd! : _rangeStart!;
      final formatter = DateFormat('yyyy-MM-dd');

      final body = {
        'year': selectedYear,
        'month': _getMonthNumber(),
        'selectedStartDate': formatter.format(start),
        'selectedEndDate': formatter.format(end),
        'isCheckedToday': active.selected == true,
      };

      final response = await ApiService2.post(
        ApiEndPoint.taskCalender,
        body: body,
      );

      final status = response?.statusCode;
      if (status == 200 || status == 201) {
        Get.snackbar('Success', 'Saved successfully',
            backgroundColor: Colors.black87, colorText: Colors.white);
        await fetchTaskCalendar();
      } else {
        Get.snackbar('Failed', 'Save failed',
            backgroundColor: Colors.black87, colorText: Colors.white);
      }
    } catch (_) {
      Get.snackbar('Failed', 'Save failed',
          backgroundColor: Colors.black87, colorText: Colors.white);
    } finally {
      isTaskSaving = false;
      update();
    }
  }

  Future<void> fetchTaskCalendar() async {
    isTaskLoading = true;
    update();
    try {
      final url = '${ApiEndPoint.taskCalender}?year=$selectedYear&month=${_getMonthNumber()}';
      final response = await ApiService2.get(url);
      if (response == null || response.statusCode != 200) {
        taskDays = [];
        isTaskLoading = false;
        update();
        return;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      if (payload == null) {
        taskDays = [];
        isTaskLoading = false;
        update();
        return;
      }

      final parsed = TaskCalendarData.fromJson(payload.cast<String, dynamic>());
      taskDays = parsed.days;

      if (parsed.selectedStartDate != null && parsed.selectedEndDate != null) {
        _rangeStart = _normalizeDate(parsed.selectedStartDate!.toLocal());
        _rangeEnd = _normalizeDate(parsed.selectedEndDate!.toLocal());
        activeDate = _rangeEnd;
      }
    } catch (_) {
      taskDays = [];
    } finally {
      isTaskLoading = false;
      update();
    }
  }

  bool isDateSelected(DateTime date) {
    return isDateInRange(date);
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void selectDate(DateTime date) {
    if (_isBeforeToday(date)) {
      return;
    }
    final normalized = _normalizeDate(date);

    if (_rangeStart == null || _rangeEnd == null) {
      _rangeStart = normalized;
      _rangeEnd = normalized;
      activeDate = normalized;
      update();
      return;
    }

    final start = _rangeStart!.isBefore(_rangeEnd!) ? _rangeStart! : _rangeEnd!;
    final end = _rangeStart!.isBefore(_rangeEnd!) ? _rangeEnd! : _rangeStart!;

    // If tapped inside existing range, just move active date.
    if (normalized.isAfter(start.subtract(const Duration(days: 1))) &&
        normalized.isBefore(end.add(const Duration(days: 1)))) {
      activeDate = normalized;
      update();
      return;
    }

    // Extend range by tapping adjacent days only.
    if (normalized.isAtSameMomentAs(start.subtract(const Duration(days: 1)))) {
      _rangeStart = normalized;
      _rangeEnd = end;
      activeDate = normalized;
      update();
      return;
    }

    if (normalized.isAtSameMomentAs(end.add(const Duration(days: 1)))) {
      _rangeStart = start;
      _rangeEnd = normalized;
      activeDate = normalized;
      update();
      return;
    }

    // Non-adjacent selection resets the range.
    _rangeStart = normalized;
    _rangeEnd = normalized;
    activeDate = normalized;
    update();
  }

  void startDragSelection(DateTime date) {
    if (_isBeforeToday(date)) {
      return;
    }
    _isDragging = true;
    final normalized = _normalizeDate(date);
    _rangeStart = normalized;
    _rangeEnd = normalized;
    activeDate = normalized;
    update();
  }

  void updateDragSelection(DateTime date) {
    if (!_isDragging) return;
    if (_isBeforeToday(date)) return;
    final normalized = _normalizeDate(date);
    _rangeEnd = normalized;
    activeDate = normalized;
    update();
  }

  void endDragSelection() {
    _isDragging = false;
  }

  void showYearPicker() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        title: const Text('Select Year', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 300,
          height: 300,
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              final year = DateTime.now().year - 5 + index;

              return GetBuilder<CalendarController>(
                builder: (_) => Container(
                  color: (year == selectedYear)
                      ? Colors.white24   // highlight selected year
                      : Colors.transparent,
                  child: ListTile(
                    title: Text(
                      year.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      selectedYear = year;
                      update();
                      Navigator.pop(Get.context!);

                      await Future.delayed(Duration(milliseconds: 120));
                      fetchTaskCalendar();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }



  void showMonthPicker() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        title: const Text('Select Month', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView.builder(
            itemCount: months.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  months[index],
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  selectedMonth = months[index];
                  update();
                  Navigator.pop(Get.context!);
                  fetchTaskCalendar();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}