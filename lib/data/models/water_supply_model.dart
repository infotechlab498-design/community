enum WaterSupplyStatus { opens, closed, available }

class WaterBlock {
  final String id;
  final String name;

  const WaterBlock({required this.id, required this.name});
}

class WaterDayInfo {
  final DateTime date;
  final bool isOpen;
  final bool isToday;
  final bool isSelected;

  const WaterDayInfo({
    required this.date,
    required this.isOpen,
    required this.isToday,
    required this.isSelected,
  });

  String get accessibilityLabel {
    final month = waterMonthName(date.month);
    final status = isOpen
        ? 'Water supply available'
        : 'Water supply unavailable';
    final today = isToday ? ', today' : '';
    return '$month ${date.day}, ${date.year}$today. $status';
  }
}

class WaterMonthSchedule {
  final WaterBlock block;
  final DateTime month;
  final Set<int> openDays;
  final DateTime? selectedDate;

  const WaterMonthSchedule({
    required this.block,
    required this.month,
    required this.openDays,
    this.selectedDate,
  });

  int get openDayCount => openDays.length;

  bool isOpen(int day) => openDays.contains(day);

  String get monthLabel => '${waterMonthName(month.month)} ${month.year}';

  static String formatFullDate(DateTime date) {
    return '${waterMonthName(date.month)} ${date.day}, ${date.year}';
  }

  WaterSupplyStatus get badgeStatus {
    if (selectedDate == null) return WaterSupplyStatus.available;
    return isOpen(selectedDate!.day)
        ? WaterSupplyStatus.opens
        : WaterSupplyStatus.closed;
  }

  String get badgeTitle {
    switch (badgeStatus) {
      case WaterSupplyStatus.opens:
        return 'Supply Opens';
      case WaterSupplyStatus.closed:
        return 'Supply Closed';
      case WaterSupplyStatus.available:
        return 'Supply Opens';
    }
  }

  String get badgeSubtitle {
    switch (badgeStatus) {
      case WaterSupplyStatus.closed:
        return 'Not this date';
      case WaterSupplyStatus.opens:
      case WaterSupplyStatus.available:
        return 'On Selected Days';
    }
  }
}

String waterMonthName(int month) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return names[month - 1];
}
