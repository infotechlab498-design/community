import 'package:flutter/material.dart';

enum PrayerType { fajr, dhuhr, asr, maghrib, isha }

enum PrayerRowStatus { past, current, upcoming }

class PrayerTime {
  final PrayerType type;
  final String name;
  final String arabicName;
  final DateTime startTime;
  final DateTime? iqamahTime;

  const PrayerTime({
    required this.type,
    required this.name,
    required this.arabicName,
    required this.startTime,
    this.iqamahTime,
  });

  IconData get icon {
    switch (type) {
      case PrayerType.fajr:
        return Icons.nights_stay_rounded;
      case PrayerType.dhuhr:
        return Icons.wb_sunny_rounded;
      case PrayerType.asr:
        return Icons.wb_cloudy_rounded;
      case PrayerType.maghrib:
        return Icons.wb_twilight;
      case PrayerType.isha:
        return Icons.dark_mode_rounded;
    }
  }

  String get accessibilityName => '$name ($arabicName)';
}

class PrayerDaySnapshot {
  final List<PrayerTime> prayers;
  final PrayerTime currentPrayer;
  final PrayerTime nextPrayer;
  final DateTime nextPrayerTime;
  final bool nextIsTomorrow;
  final DateTime now;

  const PrayerDaySnapshot({
    required this.prayers,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.nextIsTomorrow,
    required this.now,
  });

  factory PrayerDaySnapshot.compute({
    required List<PrayerTime> prayers,
    required DateTime now,
  }) {
    final ordered = List<PrayerTime>.from(prayers)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final fajr = ordered.firstWhere((p) => p.type == PrayerType.fajr);
    final isha = ordered.firstWhere((p) => p.type == PrayerType.isha);

    if (now.isBefore(fajr.startTime)) {
      return PrayerDaySnapshot(
        prayers: ordered,
        currentPrayer: isha,
        nextPrayer: fajr,
        nextPrayerTime: fajr.startTime,
        nextIsTomorrow: false,
        now: now,
      );
    }

    PrayerTime current = ordered.first;
    for (final prayer in ordered) {
      if (!now.isBefore(prayer.startTime)) {
        current = prayer;
      }
    }

    if (current.type == PrayerType.isha) {
      final tomorrowFajr = DateTime(
        fajr.startTime.year,
        fajr.startTime.month,
        fajr.startTime.day + 1,
        fajr.startTime.hour,
        fajr.startTime.minute,
      );
      return PrayerDaySnapshot(
        prayers: ordered,
        currentPrayer: current,
        nextPrayer: fajr,
        nextPrayerTime: tomorrowFajr,
        nextIsTomorrow: true,
        now: now,
      );
    }

    final currentIndex = ordered.indexWhere((p) => p.type == current.type);
    final next = ordered[currentIndex + 1];
    return PrayerDaySnapshot(
      prayers: ordered,
      currentPrayer: current,
      nextPrayer: next,
      nextPrayerTime: next.startTime,
      nextIsTomorrow: false,
      now: now,
    );
  }

  Duration get timeUntilNext {
    final remaining = nextPrayerTime.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  PrayerRowStatus rowStatus(PrayerTime prayer) {
    final index = prayers.indexWhere((item) => item.type == prayer.type);
    if (index < 0) return PrayerRowStatus.upcoming;

    final start = prayer.startTime;
    final DateTime end;
    if (prayer.type == PrayerType.isha) {
      final fajr = prayers.firstWhere((item) => item.type == PrayerType.fajr);
      end = DateTime(
        fajr.startTime.year,
        fajr.startTime.month,
        fajr.startTime.day + 1,
        fajr.startTime.hour,
        fajr.startTime.minute,
      );
    } else {
      end = prayers[index + 1].startTime;
    }

    if (!now.isBefore(start) && now.isBefore(end)) {
      return PrayerRowStatus.current;
    }
    if (now.isBefore(start)) return PrayerRowStatus.upcoming;
    return PrayerRowStatus.past;
  }

  String semanticsFor(PrayerTime prayer) {
    final status = rowStatus(prayer);
    final suffix = switch (status) {
      PrayerRowStatus.current => 'Currently active.',
      PrayerRowStatus.past => 'Already completed today.',
      PrayerRowStatus.upcoming => 'Upcoming.',
    };
    return '${prayer.name} prayer. $suffix';
  }
}

/// One admin-managed row from `GET /api/prayer-times`; [time] is "HH:mm".
class PrayerTimeSetting {
  final int id;
  final String name;
  final String time;
  final int sortOrder;

  const PrayerTimeSetting({
    required this.id,
    required this.name,
    required this.time,
    required this.sortOrder,
  });

  factory PrayerTimeSetting.fromJson(Map<String, dynamic> json) {
    return PrayerTimeSetting(
      id: json['id'] as int,
      name: json['name'] as String,
      time: json['time'] as String,
      sortOrder: (json['sortOrder'] as int?) ?? 0,
    );
  }

  PrayerTimeSetting copyWith({String? time}) => PrayerTimeSetting(
        id: id,
        name: name,
        time: time ?? this.time,
        sortOrder: sortOrder,
      );
}
