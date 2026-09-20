enum ShuttleTripStatus { departed, next, upcoming }

class ShuttleDeparture {
  final int id;
  final String time;

  const ShuttleDeparture({
    required this.id,
    required this.time,
  });

  /// Minutes from midnight for the printed 12-hour time (e.g. 07:15 AM).
  int get minutesFromMidnight {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(time.trim());
    if (match == null) return 0;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (period == 'AM') {
      if (hour == 12) hour = 0;
    } else if (hour != 12) {
      hour += 12;
    }
    return hour * 60 + minute;
  }
}

class ShuttleRoute {
  final String id;
  final String toggleLabel;
  final String origin;
  final String destination;
  final List<ShuttleDeparture> departures;

  const ShuttleRoute({
    required this.id,
    required this.toggleLabel,
    required this.origin,
    required this.destination,
    required this.departures,
  });

  String get directionLabel => '$origin → $destination';
}

class ShuttleScheduleSnapshot {
  final ShuttleRoute route;
  final DateTime now;
  final ShuttleDeparture? nextDeparture;
  final bool isTomorrow;

  const ShuttleScheduleSnapshot({
    required this.route,
    required this.now,
    required this.nextDeparture,
    required this.isTomorrow,
  });

  ShuttleTripStatus statusFor(ShuttleDeparture departure) {
    if (isTomorrow || nextDeparture == null) {
      return ShuttleTripStatus.departed;
    }
    final nowMinutes = now.hour * 60 + now.minute;
    if (departure.minutesFromMidnight <= nowMinutes) {
      return ShuttleTripStatus.departed;
    }
    if (departure.id == nextDeparture!.id) return ShuttleTripStatus.next;
    return ShuttleTripStatus.upcoming;
  }

  int minutesUntilNext() {
    final next = nextDeparture;
    if (next == null) return 0;
    final nowMinutes = now.hour * 60 + now.minute;
    if (isTomorrow) {
      return (24 * 60 - nowMinutes) + next.minutesFromMidnight;
    }
    return next.minutesFromMidnight - nowMinutes;
  }

  String nextCountdownLabel() {
    final minutes = minutesUntilNext();
    if (nextDeparture == null) return 'No trips listed';
    if (!isTomorrow && minutes <= 0) return 'Leaving now';
    if (isTomorrow) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (hours >= 1) {
        return 'First trip tomorrow in ${hours}h ${mins.toString().padLeft(2, '0')}m';
      }
      return 'First trip tomorrow in $mins min';
    }
    if (minutes < 60) return 'Leaves in $minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return 'Leaves in ${hours}h';
    return 'Leaves in ${hours}h ${mins}m';
  }
}
