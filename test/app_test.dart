import 'dart:convert';

import 'package:community/core/network/api_client.dart';
import 'package:community/core/utils/time_formatter.dart';
import 'package:community/data/models/hospital_model.dart';
import 'package:community/data/models/prayer_time_model.dart';
import 'package:community/data/models/shuttle_route_model.dart';
import 'package:community/data/models/water_schedule_model.dart';
import 'package:community/data/models/water_supply_model.dart';
import 'package:community/data/repositories/community_repository.dart';
import 'package:community/data/repositories/prayer_times_repository.dart';
import 'package:community/data/repositories/water_supply_repository.dart';
import 'package:community/features/namaztiming/prayer_times_screen.dart';
import 'package:community/features/water/water_supply_screen.dart';
import 'package:community/shared/widgets/header_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _blocksJson = [
  {'id': 'A', 'name': 'Block A'},
  {'id': 'B', 'name': 'Block B'},
  {'id': 'C', 'name': 'Block C'},
  {'id': 'E', 'name': 'Block E'},
];

const _prayerJson = [
  {'id': 1, 'name': 'Fajr', 'time': '04:17', 'sortOrder': 1},
  {'id': 2, 'name': 'Dhuhr', 'time': '12:30', 'sortOrder': 2},
  {'id': 3, 'name': 'Asr', 'time': '15:45', 'sortOrder': 3},
  {'id': 4, 'name': 'Maghrib', 'time': '18:15', 'sortOrder': 4},
  {'id': 5, 'name': 'Isha', 'time': '20:00', 'sortOrder': 5},
  {'id': 6, 'name': 'Jummah', 'time': '13:30', 'sortOrder': 6},
];

/// Same 4-day rotation the API seeds: none, C+E, B, A.
Map<String, dynamic> _monthJson(int year, int month) {
  final days = DateTime(year, month + 1, 0).day;
  return {
    'year': year,
    'month': month,
    'isPublished': true,
    'publishedAtUtc': '2026-09-01T00:00:00',
    'blocks': _blocksJson,
    'days': [
      for (var d = 1; d <= days; d++)
        {
          'date': '$year-${month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}',
          'activeBlockIds': switch (d % 4) {
            1 => <String>[],
            2 => ['C', 'E'],
            3 => ['B'],
            _ => ['A'],
          },
        },
    ],
  };
}

http.Response _json(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

ApiClient _mockApi(http.Response Function(http.Request request) handler) {
  return ApiClient(client: MockClient((request) async => handler(request)));
}

List<PrayerTimeSetting> get _prayerSettings => _prayerJson
    .map((e) => PrayerTimeSetting.fromJson(Map<String, dynamic>.from(e)))
    .toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Business logic', () {
    test('WaterScheduleItem sorts Sunday (id 0) as the last day of week', () {
      final items = [
        const WaterScheduleItem(id: 0, day: 'Sunday', time: '9:00 AM', status: 'open'),
        const WaterScheduleItem(id: 1, day: 'Monday', time: '9:00 AM', status: 'open'),
        const WaterScheduleItem(id: 6, day: 'Saturday', time: '9:00 AM', status: 'open'),
        const WaterScheduleItem(id: 3, day: 'Wednesday', time: '9:00 AM', status: 'open'),
      ]..sort((a, b) => a.sortKey.compareTo(b.sortKey));

      expect(items.map((i) => i.day), ['Monday', 'Wednesday', 'Saturday', 'Sunday']);
      expect(items.last.sortKey, 7);
    });

    test('CommunityRepository generates Monday-first week dates', () {
      final weekDates = CommunityRepository.getCurrentWeekDates(DateTime(2026, 9, 16));

      expect(weekDates.length, 7);
      expect(weekDates[0].dayName, 'MON');
      expect(weekDates[0].date, 14);
      expect(weekDates[2].isToday, isTrue);
      expect(weekDates[6].date, 20);
    });

    test('CommunityRepository official updates contains all notices', () {
      final updates = CommunityRepository.getOfficialUpdates();
      expect(updates.length, 7);
      expect(updates.where((u) => u.category == 'Maintenance').length, 2);
      expect(updates.where((u) => u.category == 'Safety').length, 2);
    });

    test('API time helpers convert HH:mm for display and maths', () {
      expect(formatApiTime('07:30'), '07:30 AM');
      expect(formatApiTime('12:00'), '12:00 PM');
      expect(formatApiTime('00:05'), '12:05 AM');
      expect(formatApiTime('20:00'), '08:00 PM');
      expect(apiTimeToMinutes('14:15'), 855);
    });

    test('ShuttleRoute parses API data and finds the next departure', () {
      final route = ShuttleRoute.fromJson({
        'id': 'lillyA',
        'origin': 'Lilly A',
        'destination': 'Main Gate',
        'departures': [
          {'id': 2, 'time': '08:00'},
          {'id': 1, 'time': '07:30'},
          {'id': 3, 'time': '20:00'},
        ],
      });

      expect(route.directionLabel, 'Lilly A → Main Gate');
      expect(route.toggleLabel, 'From Lilly A');
      expect(route.departures.first.time, '07:30 AM');

      final morning = ShuttleScheduleSnapshot.compute(route, DateTime(2026, 9, 19, 7, 0));
      expect(morning.nextDeparture?.time, '07:30 AM');
      expect(morning.isTomorrow, isFalse);
      expect(morning.nextCountdownLabel(), 'Leaves in 30 min');

      final night = ShuttleScheduleSnapshot.compute(route, DateTime(2026, 9, 19, 21, 0));
      expect(night.isTomorrow, isTrue);
      expect(night.nextDeparture?.time, '07:30 AM');
    });

    test('WaterSupplyMonth derives per-block open days from API days', () {
      final month = WaterSupplyMonth.fromJson(_monthJson(2026, 9));
      final blockA = month.scheduleFor(month.blocks.first);

      expect(blockA.monthLabel, 'September 2026');
      expect(blockA.openDays, {4, 8, 12, 16, 20, 24, 28});
      expect(blockA.activationStatusFor(DateTime(2026, 9, 30)), WaterDayActivationStatus.closed);

      final blockE = month.scheduleFor(month.blocks.last);
      expect(blockE.openDayCount, 8);
      expect(month.activeBlocksOn(DateTime(2026, 9, 2)), {'C', 'E'});
      expect(month.activeBlocksOn(DateTime(2026, 9, 1)), isEmpty);

      final request = month.toSaveRequestJson();
      expect((request['days'] as List).length, 30);
      expect((request['days'] as List)[1], {'date': '2026-09-02', 'activeBlockIds': ['C', 'E']});
    });

    test('Prayer snapshot uses Dhuhr on weekdays and Jummah on Fridays', () {
      final monday = PrayerTimesRepository.buildSnapshot(_prayerSettings, DateTime(2026, 9, 21, 13, 0));
      expect(monday.currentPrayer.name, 'Dhuhr');
      expect(monday.nextPrayer.type, PrayerType.asr);

      final friday = PrayerTimesRepository.buildSnapshot(_prayerSettings, DateTime(2026, 9, 25, 13, 0));
      expect(friday.prayers.map((p) => p.name), contains('Jummah'));
      expect(friday.prayers.map((p) => p.name), isNot(contains('Dhuhr')));
      expect(friday.currentPrayer.type, PrayerType.fajr);
      expect(friday.nextPrayer.name, 'Jummah');

      final night = PrayerTimesRepository.buildSnapshot(_prayerSettings, DateTime(2026, 9, 21, 21, 0));
      expect(night.currentPrayer.type, PrayerType.isha);
      expect(night.nextIsTomorrow, isTrue);
      expect(night.nextPrayerTime.day, 22);

      final beforeFajr = PrayerTimesRepository.buildSnapshot(_prayerSettings, DateTime(2026, 9, 21, 3, 0));
      expect(beforeFajr.nextPrayer.type, PrayerType.fajr);
      expect(beforeFajr.nextIsTomorrow, isFalse);

      expect(TimeFormatter.formatTime(DateTime(2026, 9, 21, 4, 17)), '04:17 AM');
      expect(TimeFormatter.formatCountdown(const Duration(hours: 3, minutes: 13)), '3h 13m');
    });

    test('Hospital opens Google Maps search by coordinates', () {
      const hospital = Hospital(
        id: 1,
        name: 'City Hospital',
        address: 'Islamabad',
        latitude: 33.6844,
        longitude: 73.0479,
      );

      expect(
        hospital.mapsUri.toString(),
        'https://www.google.com/maps/search/?api=1&query=33.6844%2C73.0479',
      );
    });
  });

  group('ApiClient', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('401 on an admin request clears the token and reports session expiry', () async {
      FlutterSecureStorage.setMockInitialValues({ApiClient.tokenKey: 'expired-token'});
      String? sentAuth;
      final api = _mockApi((request) {
        sentAuth = request.headers['Authorization'];
        return http.Response('', 401);
      });

      await expectLater(
        api.put('/api/admin/prayer-times', auth: true, body: {'prayers': []}),
        throwsA(isA<SessionExpiredException>()),
      );
      expect(sentAuth, 'Bearer expired-token');
      expect(await api.readToken(), isNull);
    });

    test('admin request without a stored token fails before calling the API', () async {
      var called = false;
      final api = _mockApi((_) {
        called = true;
        return _json({});
      });

      await expectLater(api.delete('/api/admin/contacts/1', auth: true),
          throwsA(isA<SessionExpiredException>()));
      expect(called, isFalse);
    });

    test('validation errors surface the first field message', () async {
      final api = _mockApi((_) => _json({
            'title': 'One or more validation errors occurred.',
            'errors': {
              'EndTime': ['End time must be after start time.'],
            },
          }, 400));

      await expectLater(
        api.post('/api/admin/gym-sessions', body: {}),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'End time must be after start time.')),
      );
    });

    test('unpublished water month returns null instead of an error', () async {
      final repository = WaterSupplyRepository(
        client: _mockApi((_) => _json({'message': 'No published schedule.'}, 404)),
      );

      expect(await repository.fetchPublishedMonth(2026, 10), isNull);
    });
  });

  group('Widgets', () {
    testWidgets('HeaderTopAppBar renders', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(appBar: HeaderTopAppBar())));
      expect(find.byType(HeaderTopAppBar), findsOneWidget);
    });

    testWidgets('WaterSupplyScreen loads blocks and month from the API', (tester) async {
      final repository = WaterSupplyRepository(
        client: _mockApi((request) {
          final path = request.url.path;
          if (path.endsWith('/blocks')) return _json(_blocksJson);
          final q = request.url.queryParameters;
          return _json(_monthJson(int.parse(q['year']!), int.parse(q['month']!)));
        }),
      );

      await tester.pumpWidget(MaterialApp(home: WaterSupplyScreen(repository: repository)));
      await tester.pumpAndSettle();

      expect(find.text('Water Service'), findsOneWidget);
      expect(find.text('Select Block'), findsOneWidget);
      expect(find.text('Block A'), findsOneWidget);
      expect(find.text('Quick Note'), findsOneWidget);

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(find.text('Block B'), findsOneWidget);
    });

    testWidgets('WaterSupplyScreen shows the empty state when nothing is published', (tester) async {
      final repository = WaterSupplyRepository(
        client: _mockApi((request) => request.url.path.endsWith('/blocks')
            ? _json(_blocksJson)
            : _json({'message': 'No published schedule.'}, 404)),
      );

      await tester.pumpWidget(MaterialApp(home: WaterSupplyScreen(repository: repository)));
      await tester.pumpAndSettle();

      expect(find.text('No schedule available'), findsOneWidget);
      expect(find.byTooltip('Previous month'), findsOneWidget);
    });

    testWidgets('WaterSupplyScreen shows retry when the API is unreachable', (tester) async {
      final repository = WaterSupplyRepository(
        client: ApiClient(client: MockClient((_) async => throw http.ClientException('offline'))),
      );

      await tester.pumpWidget(MaterialApp(home: WaterSupplyScreen(repository: repository)));
      await tester.pumpAndSettle();

      expect(find.text('Unable to update schedule'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('PrayerTimesScreen shows API prayer times without a location picker', (tester) async {
      final repository = PrayerTimesRepository(client: _mockApi((_) => _json(_prayerJson)));

      await tester.pumpWidget(MaterialApp(home: PrayerTimesScreen(repository: repository)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Assalamu Alaikum 👋'), findsOneWidget);
      expect(find.text('CURRENT PRAYER'), findsOneWidget);
      expect(find.text('Fajr'), findsWidgets);
      expect(find.text('Isha'), findsWidgets);
      expect(find.text('Community mosque timetable'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_rounded), findsNothing);
    });
  });
}
