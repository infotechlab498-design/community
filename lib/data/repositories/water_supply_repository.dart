import '../models/water_supply_model.dart';

class WaterSupplyRepository {
  WaterSupplyRepository._();

  static const List<WaterBlock> blocks = [
    WaterBlock(id: 'A', name: 'Block A'),
    WaterBlock(id: 'B', name: 'Block B'),
    WaterBlock(id: 'C', name: 'Block C'),
    WaterBlock(id: 'E', name: 'Block E'),
  ];

  static WaterBlock blockById(String id) {
    return blocks.firstWhere(
      (block) => block.id == id,
      orElse: () => blocks.first,
    );
  }

  /// Open-supply days for a block in a given month. Business logic lives here,
  /// not in calendar widgets.
  static Set<int> openDaysFor(String blockId, DateTime month) {
    final year = month.year;
    final monthNumber = month.month;
    final lastDay = DateTime(year, monthNumber + 1, 0).day;

    if (blockId == 'A' && year == 2026 && monthNumber == 9) {
      return {2, 4, 6, 10, 14, 16, 18, 20, 22, 24, 28, 30};
    }

    final open = <int>{};
    for (var day = 1; day <= lastDay; day++) {
      final date = DateTime(year, monthNumber, day);
      final include = switch (blockId) {
        'A' => day.isEven,
        'B' => day.isOdd,
        'C' => day % 3 == 0,
        'E' =>
          date.weekday == DateTime.friday || date.weekday == DateTime.saturday,
        _ => false,
      };
      if (include) open.add(day);
    }
    return open;
  }

  static WaterMonthSchedule scheduleFor({
    required String blockId,
    required DateTime month,
    DateTime? selectedDate,
  }) {
    final normalizedMonth = DateTime(month.year, month.month);
    return WaterMonthSchedule(
      block: blockById(blockId),
      month: normalizedMonth,
      openDays: openDaysFor(blockId, normalizedMonth),
      selectedDate: selectedDate,
    );
  }
}
