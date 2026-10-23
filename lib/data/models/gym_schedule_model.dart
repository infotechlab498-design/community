import '../../core/network/api_client.dart';

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

enum GymAudience { male, female }

class GymSession {
  final int id;
  final String title;
  final GymAudience audience;

  /// 24-hour "HH:mm".
  final String startTime;
  final String endTime;
  final int sortOrder;

  const GymSession({
    required this.id,
    required this.title,
    required this.audience,
    required this.startTime,
    required this.endTime,
    required this.sortOrder,
  });

  factory GymSession.fromJson(Map<String, dynamic> json) {
    return GymSession(
      id: json['id'] as int,
      title: json['title'] as String,
      audience:
          json['audience'] == 'Female' ? GymAudience.female : GymAudience.male,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      sortOrder: (json['sortOrder'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toRequestJson() => {
        'title': title,
        'audience': audience == GymAudience.female ? 'Female' : 'Male',
        'startTime': startTime,
        'endTime': endTime,
        'sortOrder': sortOrder,
      };

  String get audienceLabel =>
      audience == GymAudience.female ? 'Female' : 'Male';

  String get timeRangeLabel =>
      '${formatApiTime(startTime)} – ${formatApiTime(endTime)}';

  bool isLive(DateTime now) {
    final minutes = now.hour * 60 + now.minute;
    return minutes >= apiTimeToMinutes(startTime) &&
        minutes < apiTimeToMinutes(endTime);
  }
}
