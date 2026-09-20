import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community/core/services/location_service.dart';
import 'package:community/data/models/water_schedule_model.dart';
import 'package:community/data/models/hospital_model.dart';
import 'package:community/data/models/water_supply_model.dart';
import 'package:community/core/utils/time_formatter.dart';
import 'package:community/data/models/prayer_time_model.dart';
import 'package:community/data/repositories/prayer_times_repository.dart';
import 'package:community/features/namaztiming/prayer_times_screen.dart';
import 'package:community/data/repositories/community_repository.dart';
import 'package:community/data/repositories/water_supply_repository.dart';
import 'package:community/features/water/water_supply_screen.dart';
import 'package:community/shared/widgets/header_top_app_bar.dart';

void main() {
  group('Business Logic & Algorithm Tests', () {
    test(
      'WaterScheduleItem sorts Sunday (id 0) as the last day of week (7)',
      () {
        final items = [
          const WaterScheduleItem(
            id: 0,
            day: 'Sunday',
            time: '9:00 AM',
            status: 'open',
          ),
          const WaterScheduleItem(
            id: 1,
            day: 'Monday',
            time: '9:00 AM',
            status: 'open',
          ),
          const WaterScheduleItem(
            id: 6,
            day: 'Saturday',
            time: '9:00 AM',
            status: 'open',
          ),
          const WaterScheduleItem(
            id: 3,
            day: 'Wednesday',
            time: '9:00 AM',
            status: 'open',
          ),
        ];

        items.sort((a, b) => a.sortKey.compareTo(b.sortKey));

        expect(items.first.day, 'Monday');
        expect(items[1].day, 'Wednesday');
        expect(items[2].day, 'Saturday');
        expect(items.last.day, 'Sunday');
        expect(items.last.sortKey, 7);
      },
    );

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

    test(
      'CommunityRepository shuttle datasets match 13 departures per route',
      () {
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
      },
    );

    test('CommunityRepository official updates contains all 7 categories and notices', () {
      final updates = CommunityRepository.getOfficialUpdates();
      expect(updates.length, 7);

      final maintenance = updates
          .where((u) => u.category == 'Maintenance')
          .toList();
      final safety = updates.where((u) => u.category == 'Safety').toList();
      final social = updates
          .where((u) => u.category == 'Social Events')
          .toList();
      final utilities = updates
          .where((u) => u.category == 'Utilities')
          .toList();

      expect(maintenance.length, 2);
      expect(safety.length, 2);
      expect(social.length, 1);
      expect(utilities.length, 2);
    });

    test(
      'WaterSupplyRepository uses official September 2026 block schedule',
      () {
        final september = DateTime(2026, 9);

        expect(WaterSupplyRepository.openDaysFor('A', september), {
          4,
          8,
          12,
          16,
          20,
          24,
          28,
        });
        expect(WaterSupplyRepository.openDaysFor('B', september), {
          3,
          7,
          11,
          15,
          19,
          23,
          27,
        });
        expect(WaterSupplyRepository.openDaysFor('C', september), {
          2,
          6,
          10,
          14,
          18,
          22,
          26,
          30,
        });
        expect(WaterSupplyRepository.openDaysFor('E', september), {
          2,
          6,
          10,
          14,
          18,
          22,
          26,
          30,
        });

        final blockA = WaterSupplyRepository.scheduleFor(
          blockId: 'A',
          month: september,
        );
        expect(blockA.monthLabel, 'September 2026');
        expect(blockA.openDayCount, 7);
        expect(
          blockA.activationStatusFor(DateTime(2026, 9, 4)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockA.activationStatusFor(DateTime(2026, 9, 8)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockA.activationStatusFor(DateTime(2026, 9, 12)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockA.activationStatusFor(DateTime(2026, 9, 16)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockA.activationStatusFor(DateTime(2026, 9, 20)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockA.activationStatusFor(DateTime(2026, 9, 24)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockA.activationStatusFor(DateTime(2026, 9, 28)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockA.activationStatusFor(DateTime(2026, 9, 30)),
          WaterDayActivationStatus.closed,
        );

        final blockB = WaterSupplyRepository.scheduleFor(
          blockId: 'B',
          month: september,
        );
        expect(blockB.openDayCount, 7);
        expect(
          blockB.activationStatusFor(DateTime(2026, 9, 3)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockB.activationStatusFor(DateTime(2026, 9, 7)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockB.activationStatusFor(DateTime(2026, 9, 11)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockB.activationStatusFor(DateTime(2026, 9, 15)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockB.activationStatusFor(DateTime(2026, 9, 19)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockB.activationStatusFor(DateTime(2026, 9, 23)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockB.activationStatusFor(DateTime(2026, 9, 27)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockB.activationStatusFor(DateTime(2026, 9, 28)),
          WaterDayActivationStatus.closed,
        );

        final blockC = WaterSupplyRepository.scheduleFor(
          blockId: 'C',
          month: september,
        );
        expect(blockC.openDayCount, 8);
        expect(
          blockC.activationStatusFor(DateTime(2026, 9, 2)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockC.activationStatusFor(DateTime(2026, 9, 6)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockC.activationStatusFor(DateTime(2026, 9, 10)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockC.activationStatusFor(DateTime(2026, 9, 14)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockC.activationStatusFor(DateTime(2026, 9, 18)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockC.activationStatusFor(DateTime(2026, 9, 22)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockC.activationStatusFor(DateTime(2026, 9, 26)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockC.activationStatusFor(DateTime(2026, 9, 30)),
          WaterDayActivationStatus.open,
        );

        final blockE = WaterSupplyRepository.scheduleFor(
          blockId: 'E',
          month: september,
        );
        expect(blockE.openDayCount, 8);
        expect(WaterSupplyRepository.activeBlocksOn(DateTime(2026, 9, 2)), {
          'C',
          'E',
        });
        expect(
          blockE.activationStatusFor(DateTime(2026, 9, 2)),
          WaterDayActivationStatus.open,
        );
        expect(
          blockE.activationStatusFor(DateTime(2026, 9, 30)),
          WaterDayActivationStatus.open,
        );

        const closedForAll = [1, 5, 9, 13, 17, 21, 25, 29];
        for (final day in closedForAll) {
          final date = DateTime(2026, 9, day);
          expect(WaterSupplyRepository.activeBlocksOn(date), isEmpty);
          for (final block in WaterSupplyRepository.blocks) {
            expect(
              WaterSupplyRepository.activationStatus(
                blockId: block.id,
                date: date,
              ),
              WaterDayActivationStatus.closed,
            );
          }
        }
      },
    );

    test('PrayerDaySnapshot identifies current and next prayers including Isha rollover', () {
      const repo = LocalPrayerTimesRepository();
      final day = DateTime(2026, 9, 21);
      final times = repo.timesFor(day);

      final morning = PrayerDaySnapshot.compute(
        location: PrayerLocation.rawalpindi,
        prayers: times,
        now: DateTime(2026, 9, 21, 4, 30),
      );
      expect(morning.currentPrayer.type, PrayerType.fajr);
      expect(morning.nextPrayer.type, PrayerType.dhuhr);
      expect(morning.rowStatus(times.first), PrayerRowStatus.current);

      final afternoon = PrayerDaySnapshot.compute(
        location: PrayerLocation.rawalpindi,
        prayers: times,
        now: DateTime(2026, 9, 21, 13, 0),
      );
      expect(afternoon.currentPrayer.type, PrayerType.dhuhr);
      expect(afternoon.nextPrayer.type, PrayerType.asr);

      final night = PrayerDaySnapshot.compute(
        location: PrayerLocation.rawalpindi,
        prayers: times,
        now: DateTime(2026, 9, 21, 21, 0),
      );
      expect(night.currentPrayer.type, PrayerType.isha);
      expect(night.nextPrayer.type, PrayerType.fajr);
      expect(night.nextIsTomorrow, isTrue);
      expect(night.nextPrayerTime.day, 22);

      final beforeFajr = PrayerDaySnapshot.compute(
        location: PrayerLocation.rawalpindi,
        prayers: times,
        now: DateTime(2026, 9, 21, 3, 0),
      );
      expect(beforeFajr.currentPrayer.type, PrayerType.isha);
      expect(beforeFajr.nextPrayer.type, PrayerType.fajr);
      expect(beforeFajr.nextIsTomorrow, isFalse);

      expect(
        TimeFormatter.formatTime(DateTime(2026, 9, 21, 4, 17)),
        '04:17 AM',
      );
      expect(
        TimeFormatter.formatCountdown(const Duration(hours: 3, minutes: 13)),
        '3h 13m',
      );
      expect(TimeFormatter.formatCountdown(const Duration(minutes: 42)), '42m');
      expect(
        TimeFormatter.greetingFor(DateTime(2026, 9, 21, 9, 0)),
        'Good Morning',
      );
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
    testWidgets('HeaderTopAppBar renders with logo or fallback text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(appBar: HeaderTopAppBar())),
      );

      expect(find.byType(HeaderTopAppBar), findsOneWidget);
    });

    testWidgets('WaterSupplyScreen shows block selector and current month', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: WaterSupplyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Water Service'), findsOneWidget);
      expect(find.text('Select Block'), findsOneWidget);
      expect(find.text('Block A'), findsOneWidget);
      expect(find.text('Water Supply Open'), findsOneWidget);
      expect(find.text('Quick Note'), findsOneWidget);

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(find.text('Block B'), findsOneWidget);
    });

    testWidgets('PrayerTimesScreen shows greeting and today\'s prayers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PrayerTimesScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.text('Assalamu Alaikum 👋'), findsOneWidget);
      expect(find.text('CURRENT PRAYER'), findsOneWidget);
      expect(find.text('Fajr'), findsWidgets);
      expect(find.text('Dhuhr'), findsWidgets);
      expect(find.text('Isha'), findsWidgets);
      expect(find.text('Next Prayer'), findsOneWidget);
    });
  });
}
