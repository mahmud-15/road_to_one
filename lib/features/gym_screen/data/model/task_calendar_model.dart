class TaskCalendarDay {
  final String day;
  bool selected;
  final String work;
  final bool active;

  TaskCalendarDay({
    required this.day,
    required this.selected,
    required this.work,
    required this.active,
  });

  factory TaskCalendarDay.fromJson(Map<String, dynamic> json) {
    return TaskCalendarDay(
      day: json['day']?.toString() ?? '',
      selected: json['selected'] == true,
      work: json['work']?.toString() ?? '',
      active: json['active'] == true,
    );
  }
}

class TaskCalendarData {
  final int year;
  final int month;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final List<TaskCalendarDay> days;

  TaskCalendarData({
    required this.year,
    required this.month,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.days,
  });

  factory TaskCalendarData.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      final s = value.toString();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    return TaskCalendarData(
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
      selectedStartDate: parseDate(json['selectedStartDate']),
      selectedEndDate: parseDate(json['selectedEndDate']),
      days: (json['days'] as List?)
              ?.map((e) => TaskCalendarDay.fromJson((e as Map).cast<String, dynamic>()))
              .toList() ??
          const <TaskCalendarDay>[],
    );
  }
}
