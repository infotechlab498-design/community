class WaterScheduleItem {
  final int id;
  final String day;
  final String time;
  final String status;

  const WaterScheduleItem({
    required this.id,
    required this.day,
    required this.time,
    required this.status,
  });

  factory WaterScheduleItem.fromJson(Map<String, dynamic> json) {
    return WaterScheduleItem(
      id: json['id'] as int,
      day: json['day'] as String,
      time: json['time'] as String,
      status: json['status'] as String,
    );
  }

  /// Sort key placing Sunday (id == 0) as the last day (7), matching Monday-Sunday order
  int get sortKey => id == 0 ? 7 : id;
}
