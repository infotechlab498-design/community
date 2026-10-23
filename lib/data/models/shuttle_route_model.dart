import '../../core/network/api_client.dart';

enum ShuttleTripStatus { departed, next, upcoming }

class ShuttleDeparture {
  final int id;

  /// 24-hour "HH:mm" as stored by the API.
  final String time24;

  const ShuttleDeparture({required this.id, required this.time24});

  factory ShuttleDeparture.fromJson(Map<String, dynamic> json) {
    return ShuttleDeparture(
      id: json['id'] as int,
      time24: json['time'] as String,
    );
  }

  /// Display form, e.g. "07:30 AM".
  String get time => formatApiTime(time24);

  int get minutesFromMidnight => apiTimeToMinutes(time24);
}

class ShuttleRoute {
  final String id;
  final String origin;
  final String destination;
  final List<ShuttleDeparture> departures;

  const ShuttleRoute({
    required this.id,
    required this.origin,
    required this.destination,
    required this.departures,
  });

  factory ShuttleRoute.fromJson(Map<String, dynamic> json) {
    final departures = (json['departures'] as List? ?? const [])
        .map((e) => ShuttleDeparture.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.minutesFromMidnight.compareTo(b.minutesFromMidnight));
    return ShuttleRoute(
      id: json['id'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      departures: departures,
    );
  }

  String get toggleLabel => 'From $origin';

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

  factory ShuttleScheduleSnapshot.compute(ShuttleRoute route, [DateTime? now]) {
    final current = now ?? DateTime.now();
    final nowMinutes = current.hour * 60 + current.minute;
    ShuttleDeparture? next;
    for (final departure in route.departures) {
      if (departure.minutesFromMidnight > nowMinutes) {
        next = departure;
        break;
      }
    }
    final isTomorrow = next == null && route.departures.isNotEmpty;
    return ShuttleScheduleSnapshot(
      route: route,
      now: current,
      nextDeparture: isTomorrow ? route.departures.first : next,
      isTomorrow: isTomorrow,
    );
  }

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
