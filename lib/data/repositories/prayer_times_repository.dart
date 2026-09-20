import '../models/prayer_time_model.dart';

abstract class PrayerTimesRepository {
  Future<PrayerDaySnapshot> loadSchedule({
    required PrayerLocation location,
    DateTime? now,
  });
}

/// Community timetable for NeighborHub. Times match the published
/// Rawalpindi reference and can later be replaced by a calculation API.
class LocalPrayerTimesRepository implements PrayerTimesRepository {
  const LocalPrayerTimesRepository();

  static DateTime _at(DateTime day, int hour, int minute) {
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  List<PrayerTime> timesFor(DateTime day) {
    return [
      PrayerTime(
        type: PrayerType.fajr,
        name: 'Fajr',
        arabicName: 'الفجر',
        startTime: _at(day, 4, 17),
      ),
      PrayerTime(
        type: PrayerType.dhuhr,
        name: 'Dhuhr',
        arabicName: 'الظهر',
        startTime: _at(day, 12, 30),
      ),
      PrayerTime(
        type: PrayerType.asr,
        name: 'Asr',
        arabicName: 'العصر',
        startTime: _at(day, 15, 45),
      ),
      PrayerTime(
        type: PrayerType.maghrib,
        name: 'Maghrib',
        arabicName: 'المغرب',
        startTime: _at(day, 18, 15),
      ),
      PrayerTime(
        type: PrayerType.isha,
        name: 'Isha',
        arabicName: 'العشاء',
        startTime: _at(day, 20, 0),
      ),
    ];
  }

  @override
  Future<PrayerDaySnapshot> loadSchedule({
    required PrayerLocation location,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    return PrayerDaySnapshot.compute(
      location: location,
      prayers: timesFor(clock),
      now: clock,
    );
  }
}
