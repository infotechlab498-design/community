enum WaterSupplyStatus { opens, closed, available }

/// Calendar-cell activation for the currently selected block.
enum WaterDayActivationStatus { open, closed }

class WaterBlock {
  final String id;
  final String name;

  const WaterBlock({required this.id, required this.name});
}

/// One published calendar date and which blocks receive supply that day.
class WaterSupplyDayRecord {
  final DateTime date;
  final Set<String> activeBlockIds;

  const WaterSupplyDayRecord({
    required this.date,
    required this.activeBlockIds,
  });

  bool isBlockActive(String blockId) => activeBlockIds.contains(blockId);

  WaterDayActivationStatus statusFor(String blockId) {
    return isBlockActive(blockId)
        ? WaterDayActivationStatus.open
        : WaterDayActivationStatus.closed;
  }
}

class WaterDayInfo {
  final DateTime date;
  final WaterDayActivationStatus activationStatus;
  final bool isToday;
  final bool isSelected;

  const WaterDayInfo({
    required this.date,
    required this.activationStatus,
    required this.isToday,
    required this.isSelected,
  });

  bool get isOpen => activationStatus == WaterDayActivationStatus.open;

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

  WaterDayActivationStatus activationStatusFor(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (normalized.year != month.year || normalized.month != month.month) {
      return WaterDayActivationStatus.closed;
    }
    return isOpen(normalized.day)
        ? WaterDayActivationStatus.open
        : WaterDayActivationStatus.closed;
  }

  String get monthLabel => '${waterMonthName(month.month)} ${month.year}';

  static String formatFullDate(DateTime date) {
    return '${waterMonthName(date.month)} ${date.day}, ${date.year}';
  }

  WaterSupplyStatus get badgeStatus {
    if (selectedDate == null) return WaterSupplyStatus.available;
    return activationStatusFor(selectedDate!) == WaterDayActivationStatus.open
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

DateTime waterDateKey(DateTime date) =>
    DateTime(date.year, date.month, date.day);

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
