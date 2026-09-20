import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/constants/app_assets.dart';
import '../models/water_schedule_model.dart';
import '../models/hospital_model.dart';
import '../models/shuttle_route_model.dart';
import '../models/update_notice_model.dart';
import '../models/gym_schedule_model.dart';

class CommunityRepository {
  /// Loads water distribution timetable from bundled assets/data/waterSchedule.json
  static Future<List<WaterScheduleItem>> loadWaterSchedule() async {
    final jsonStr = await rootBundle.loadString(AppAssets.waterScheduleJson);
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((item) => WaterScheduleItem.fromJson(item)).toList();
  }

  /// Loads hospital coordinates from bundled assets/data/hospitals.json
  static Future<List<HospitalLocation>> loadHospitals() async {
    final jsonStr = await rootBundle.loadString(AppAssets.hospitalsJson);
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((item) => HospitalLocation.fromJson(item)).toList();
  }

  static const String shuttleFromLillyA = 'lillyA';
  static const String shuttleFromMainGate = 'mainGate';

  /// Lilly A → Main Gate departure times.
  static const List<ShuttleDeparture> lillyAToMainGate = [
    ShuttleDeparture(id: 1, time: '07:30 AM'),
    ShuttleDeparture(id: 2, time: '08:00 AM'),
    ShuttleDeparture(id: 3, time: '09:00 AM'),
    ShuttleDeparture(id: 4, time: '10:00 AM'),
    ShuttleDeparture(id: 5, time: '11:00 AM'),
    ShuttleDeparture(id: 6, time: '12:00 PM'),
    ShuttleDeparture(id: 7, time: '02:15 PM'),
    ShuttleDeparture(id: 8, time: '03:00 PM'),
    ShuttleDeparture(id: 9, time: '04:00 PM'),
    ShuttleDeparture(id: 10, time: '05:15 PM'),
    ShuttleDeparture(id: 11, time: '06:15 PM'),
    ShuttleDeparture(id: 12, time: '07:15 PM'),
    ShuttleDeparture(id: 13, time: '08:00 PM'),
  ];

  /// Main Gate → Lilly A departure times.
  static const List<ShuttleDeparture> mainGateToLillyA = [
    ShuttleDeparture(id: 1, time: '07:45 AM'),
    ShuttleDeparture(id: 2, time: '08:30 AM'),
    ShuttleDeparture(id: 3, time: '09:30 AM'),
    ShuttleDeparture(id: 4, time: '10:30 AM'),
    ShuttleDeparture(id: 5, time: '11:30 AM'),
    ShuttleDeparture(id: 6, time: '12:30 PM'),
    ShuttleDeparture(id: 7, time: '02:45 PM'),
    ShuttleDeparture(id: 8, time: '03:30 PM'),
    ShuttleDeparture(id: 9, time: '04:30 PM'),
    ShuttleDeparture(id: 10, time: '05:45 PM'),
    ShuttleDeparture(id: 11, time: '06:45 PM'),
    ShuttleDeparture(id: 12, time: '07:30 PM'),
    ShuttleDeparture(id: 13, time: '08:30 PM'),
  ];

  static ShuttleRoute getShuttleRoute(String routeId) {
    if (routeId == shuttleFromMainGate) {
      return const ShuttleRoute(
        id: shuttleFromMainGate,
        toggleLabel: 'From Main Gate',
        origin: 'Main Gate',
        destination: 'Lilly A',
        departures: mainGateToLillyA,
      );
    }
    return const ShuttleRoute(
      id: shuttleFromLillyA,
      toggleLabel: 'From Lilly A',
      origin: 'Lilly A',
      destination: 'Main Gate',
      departures: lillyAToMainGate,
    );
  }

  static ShuttleScheduleSnapshot getShuttleSchedule(
    String routeId, [
    DateTime? now,
  ]) {
    final route = getShuttleRoute(routeId);
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

  /// Returns official community update notices
  static List<UpdateNotice> getOfficialUpdates() {
    return const [
      UpdateNotice(
        category: 'Maintenance',
        tag: 'High Urgency',
        date: 'October 24, 2023',
        title: 'Scheduled Water \nMain Maintenance:\nNorth Sector',
        description:
            'Please be advised that water services will be temporarily suspended for the entire North Sector this coming Sunday between 8:00 AM & 4:00PM to facilitate urgent pipe upgrades.',
        imageAsset: AppAssets.detailedSchedule,
      ),
      UpdateNotice(
        category: 'Maintenance',
        tag: 'Planned',
        date: 'Phase 1: Starting Nov 1',
        title: 'Main Lobby Renovation\nProject',
        description:
            "We're enhancing the entrance experience with new sustainable lighting and ergonomic seating areas. Access will be redirected to the side entrance.",
        imageAsset: AppAssets.upgrade,
      ),
      UpdateNotice(
        category: 'Social Events',
        tag: 'Info',
        date: '2 days ago',
        title: 'Annual Garden Festival Details',
        description:
            'Registration for the autumn plant swap is now open. Join your neighbors for a morning of exchange and community growth.',
        imageAsset: AppAssets.plantIcon,
        secondaryImageAsset: AppAssets.plantArrow,
      ),
      UpdateNotice(
        category: 'Safety',
        tag: 'General',
        date: 'Oct 20',
        title: 'New Visitor Parking Policy',
        description:
            'Digital permits are now mandatory for overnight guests. Please update your registration in the portal.',
        imageAsset: AppAssets.parking,
      ),
      UpdateNotice(
        category: 'Safety',
        tag: 'Urgent',
        date: 'Today, 5:00 PM',
        title: 'Elevator B Inspection',
        description:
            'Temporarily offline for bi-annual safety certification. Estimated completion: Today, 5:00 PM.',
        imageAsset: AppAssets.inProgress,
        statusBadge: 'In Progress',
      ),
      UpdateNotice(
        category: 'Utilities',
        tag: 'Info',
        date: 'Oct 18',
        title: 'Package Room Updates',
        description:
            'Extended hours for the holiday season starting next Monday.',
        imageAsset: AppAssets.packageRoom,
      ),
      UpdateNotice(
        category: 'Utilities',
        tag: 'Info',
        date: 'Oct 17',
        title: 'E-Waste Collection',
        description:
            'Monthly electronic waste pick-up scheduled for this Friday in the south bay.',
        imageAsset: AppAssets.eWaste,
      ),
    ];
  }

  /// Calculates the 7 dates of the current week from Monday to Sunday (matching React Native gymTiming.jsx)
  static List<GymDayItem> getCurrentWeekDates([DateTime? testDate]) {
    final now = testDate ?? DateTime.now();
    // Monday is weekday 1, Sunday is weekday 7
    final currentWeekday = now.weekday; // 1 = Mon, ..., 7 = Sun
    final monday = now.subtract(Duration(days: currentWeekday - 1));

    const dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final List<GymDayItem> items = [];

    for (int i = 0; i < 7; i++) {
      final dayDate = monday.add(Duration(days: i));
      final isToday = dayDate.year == now.year &&
          dayDate.month == now.month &&
          dayDate.day == now.day;
      items.add(GymDayItem(
        dayName: dayNames[i],
        date: dayDate.day,
        isToday: isToday,
      ));
    }

    return items;
  }
}
