import '../models/water_supply_model.dart';

class WaterSupplyRepository {
  WaterSupplyRepository._();

  static const List<WaterBlock> blocks = [
    WaterBlock(id: 'A', name: 'Block A'),
    WaterBlock(id: 'B', name: 'Block B'),
    WaterBlock(id: 'C', name: 'Block C'),
    WaterBlock(id: 'E', name: 'Block E'),
  ];

  /// Official published supply days: date → active block ids.
  /// September 2026 is the current source of truth. Dates with no blocks
  /// (including 29-Sep-2026, which is blank in the source) are stored as
  /// empty sets so they are never inferred.
  static final Map<DateTime, Set<String>> _publishedActiveBlocks = {
    DateTime(2026, 9, 1): const {},
    DateTime(2026, 9, 2): const {'C', 'E'},
    DateTime(2026, 9, 3): const {'B'},
    DateTime(2026, 9, 4): const {'A'},
    DateTime(2026, 9, 5): const {},
    DateTime(2026, 9, 6): const {'C', 'E'},
    DateTime(2026, 9, 7): const {'B'},
    DateTime(2026, 9, 8): const {'A'},
    DateTime(2026, 9, 9): const {},
    DateTime(2026, 9, 10): const {'C', 'E'},
    DateTime(2026, 9, 11): const {'B'},
    DateTime(2026, 9, 12): const {'A'},
    DateTime(2026, 9, 13): const {},
    DateTime(2026, 9, 14): const {'C', 'E'},
    DateTime(2026, 9, 15): const {'B'},
    DateTime(2026, 9, 16): const {'A'},
    DateTime(2026, 9, 17): const {},
    DateTime(2026, 9, 18): const {'C', 'E'},
    DateTime(2026, 9, 19): const {'B'},
    DateTime(2026, 9, 20): const {'A'},
    DateTime(2026, 9, 21): const {},
    DateTime(2026, 9, 22): const {'C', 'E'},
    DateTime(2026, 9, 23): const {'B'},
    DateTime(2026, 9, 24): const {'A'},
    DateTime(2026, 9, 25): const {},
    DateTime(2026, 9, 26): const {'C', 'E'},
    DateTime(2026, 9, 27): const {'B'},
    DateTime(2026, 9, 28): const {'A'},
    DateTime(2026, 9, 29): const {},
    DateTime(2026, 9, 30): const {'C', 'E'},
  };

  static WaterBlock blockById(String id) {
    return blocks.firstWhere(
      (block) => block.id == id,
      orElse: () => blocks.first,
    );
  }

  static WaterSupplyDayRecord dayRecord(DateTime date) {
    final key = waterDateKey(date);
    return WaterSupplyDayRecord(date: key, activeBlockIds: activeBlocksOn(key));
  }

  static Set<String> activeBlocksOn(DateTime date) {
    return _publishedActiveBlocks[waterDateKey(date)] ?? const {};
  }

  static bool isBlockActive(String blockId, DateTime date) {
    return dayRecord(date).isBlockActive(blockId);
  }

  static WaterDayActivationStatus activationStatus({
    required String blockId,
    required DateTime date,
  }) {
    return dayRecord(date).statusFor(blockId);
  }

  /// Open-supply days for a block in a given month, derived from published
  /// date → block records. Calendar widgets must not invent these dates.
  static Set<int> openDaysFor(String blockId, DateTime month) {
    final year = month.year;
    final monthNumber = month.month;
    final lastDay = DateTime(year, monthNumber + 1, 0).day;
    final open = <int>{};
    for (var day = 1; day <= lastDay; day++) {
      if (isBlockActive(blockId, DateTime(year, monthNumber, day))) {
        open.add(day);
      }
    }
    return open;
  }

  static WaterMonthSchedule scheduleFor({
    required String blockId,
    required DateTime month,
    DateTime? selectedDate,
  }) {
    final normalizedMonth = DateTime(month.year, month.month);
    DateTime? selected;
    if (selectedDate != null) {
      selected = waterDateKey(selectedDate);
    }
    return WaterMonthSchedule(
      block: blockById(blockId),
      month: normalizedMonth,
      openDays: openDaysFor(blockId, normalizedMonth),
      selectedDate: selected,
    );
  }
}
