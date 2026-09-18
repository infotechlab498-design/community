class GymDayItem {
  final String dayName; // "SUN", "MON", etc.
  final int date;       // 1-31
  final bool isToday;

  const GymDayItem({
    required this.dayName,
    required this.date,
    required this.isToday,
  });
}

class GymSessionBlock {
  final String tag;
  final String title;
  final String time;
  final String buttonText;
  final bool isSoldOut;

  const GymSessionBlock({
    required this.tag,
    required this.title,
    required this.time,
    required this.buttonText,
    this.isSoldOut = false,
  });
}
