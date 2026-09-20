import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community/core/services/location_service.dart';
import 'package:community/data/models/water_schedule_model.dart';
import 'package:community/data/models/hospital_model.dart';
import 'package:community/data/repositories/community_repository.dart';
import 'package:community/shared/widgets/header_top_app_bar.dart';

void main() {
  group('Business Logic & Algorithm Tests', () {
    test('WaterScheduleItem sorts Sunday (id 0) as the last day of week (7)', () {
      final items = [
        const WaterScheduleItem(id: 0, day: 'Sunday', time: '9:00 AM', status: 'open'),
        const WaterScheduleItem(id: 1, day: 'Monday', time: '9:00 AM', status: 'open'),
        const WaterScheduleItem(id: 6, day: 'Saturday', time: '9:00 AM', status: 'open'),
        const WaterScheduleItem(id: 3, day: 'Wednesday', time: '9:00 AM', status: 'open'),
      ];

      items.sort((a, b) => a.sortKey.compareTo(b.sortKey));

      expect(items.first.day, 'Monday');
      expect(items[1].day, 'Wednesday');
      expect(items[2].day, 'Saturday');
      expect(items.last.day, 'Sunday');
      expect(items.last.sortKey, 7);
    });

    test('LocationService accurately converts meters to miles (1 meter = 0.000621371 miles)', () {
      const double distanceMeters = 5000; // 5 kilometers
      final milesStr = LocationService.convertMetersToMiles(distanceMeters);

      // 5000 * 0.000621371 = 3.106855 miles -> 3.1
      expect(milesStr, '3.1');
    });

    test('CommunityRepository generates 7 days starting with Monday for current week', () {
      // Test with Wednesday, Sept 16, 2026
      final testWednesday = DateTime(2026, 9, 16);
      final weekDates = CommunityRepository.getCurrentWeekDates(testWednesday);

      expect(weekDates.length, 7);
      expect(weekDates[0].dayName, 'MON');
      expect(weekDates[0].date, 14); // Monday Sept 14
      expect(weekDates[2].dayName, 'WED');
      expect(weekDates[2].date, 16); // Wednesday Sept 16
      expect(weekDates[2].isToday, isTrue);
      expect(weekDates[6].dayName, 'SUN');
      expect(weekDates[6].date, 20); // Sunday Sept 20
    });

    test('CommunityRepository shuttle datasets match 13 departures per route', () {
      final fromLillyA = CommunityRepository.getShuttleRoute(
        CommunityRepository.shuttleFromLillyA,
      );
      final fromMainGate = CommunityRepository.getShuttleRoute(
        CommunityRepository.shuttleFromMainGate,
      );

      expect(fromLillyA.departures.length, 13);
      expect(fromLillyA.departures.first.time, '07:30 AM');
      expect(fromLillyA.departures.last.time, '08:00 PM');
      expect(fromLillyA.directionLabel, 'Lilly A → Main Gate');

      expect(fromMainGate.departures.length, 13);
      expect(fromMainGate.departures.first.time, '07:45 AM');
      expect(fromMainGate.departures.last.time, '08:30 PM');
      expect(fromMainGate.directionLabel, 'Main Gate → Lilly A');

      final morning = CommunityRepository.getShuttleSchedule(
        CommunityRepository.shuttleFromLillyA,
        DateTime(2026, 9, 19, 7, 0),
      );
      expect(morning.nextDeparture?.time, '07:30 AM');
      expect(morning.isTomorrow, isFalse);
    });

    test('CommunityRepository official updates contains all 7 categories and notices', () {
      final updates = CommunityRepository.getOfficialUpdates();
      expect(updates.length, 7);

      final maintenance = updates.where((u) => u.category == 'Maintenance').toList();
      final safety = updates.where((u) => u.category == 'Safety').toList();
      final social = updates.where((u) => u.category == 'Social Events').toList();
      final utilities = updates.where((u) => u.category == 'Utilities').toList();

      expect(maintenance.length, 2);
      expect(safety.length, 2);
      expect(social.length, 1);
      expect(utilities.length, 2);
    });

    test('HospitalLocation model copyWithDistance works correctly', () {
      const hospital = HospitalLocation(
        id: 1,
        name: 'City Hospital',
        latitude: 33.6844,
        longitude: 73.0479,
      );

      final updated = hospital.copyWithDistance(
        distanceMeters: 12000,
        distanceMiles: '7.5',
      );

      expect(updated.id, 1);
      expect(updated.name, 'City Hospital');
      expect(updated.distanceMeters, 12000);
      expect(updated.distanceMiles, '7.5');
    });
  });

  group('Widget Parity Tests', () {
    testWidgets('HeaderTopAppBar renders with logo or fallback text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: HeaderTopAppBar(),
          ),
        ),
      );

      expect(find.byType(HeaderTopAppBar), findsOneWidget);
    });
  });
}
