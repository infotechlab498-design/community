import '../../core/network/api_client.dart';
import '../models/prayer_time_model.dart';

class PrayerTimesRepository {
  PrayerTimesRepository({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  static const Map<String, String> _arabicNames = {
    'Fajr': 'الفجر',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
    'Jummah': 'الجمعة',
  };

  static const Map<String, PrayerType> _dailyTypes = {
    'Fajr': PrayerType.fajr,
    'Dhuhr': PrayerType.dhuhr,
    'Asr': PrayerType.asr,
    'Maghrib': PrayerType.maghrib,
    'Isha': PrayerType.isha,
  };

  Future<List<PrayerTimeSetting>> fetchSettings() async {
    final decoded = await _api.get('/api/prayer-times');
    if (decoded is! List) {
      throw const ApiException('The API returned invalid prayer times.');
    }
    return decoded
        .map((e) => PrayerTimeSetting.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<List<PrayerTimeSetting>> saveSettings(
      List<PrayerTimeSetting> settings) async {
    final decoded = await _api.put(
      '/api/admin/prayer-times',
      auth: true,
      body: {
        'prayers': [
          for (final s in settings) {'id': s.id, 'time': s.time},
        ],
      },
    );
    return (decoded as List)
        .map((e) => PrayerTimeSetting.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<PrayerDaySnapshot> loadSchedule({DateTime? now}) async {
    final clock = now ?? DateTime.now();
    return buildSnapshot(await fetchSettings(), clock);
  }

  /// Builds today's five daily prayers. On Fridays the Dhuhr row shows Jummah.
  static PrayerDaySnapshot buildSnapshot(
      List<PrayerTimeSetting> settings, DateTime now) {
    final byName = {for (final s in settings) s.name: s};
    final isFriday = now.weekday == DateTime.friday;

    final prayers = <PrayerTime>[];
    for (final entry in _dailyTypes.entries) {
      var setting = byName[entry.key];
      if (entry.value == PrayerType.dhuhr && isFriday && byName['Jummah'] != null) {
        setting = byName['Jummah'];
      }
      if (setting == null) {
        throw ApiException('${entry.key} time is missing.');
      }
      final minutes = apiTimeToMinutes(setting.time);
      prayers.add(PrayerTime(
        type: entry.value,
        name: setting.name,
        arabicName: _arabicNames[setting.name] ?? '',
        startTime: DateTime(now.year, now.month, now.day, minutes ~/ 60, minutes % 60),
      ));
    }

    return PrayerDaySnapshot.compute(prayers: prayers, now: now);
  }
}
