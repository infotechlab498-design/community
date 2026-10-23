import '../../core/network/api_client.dart';
import '../models/water_schedule_model.dart';

class WaterScheduleApi {
  WaterScheduleApi({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<List<WaterScheduleItem>> getSchedule() async {
    final decoded = await _api.get('/api/water-schedule');
    if (decoded is! List) {
      throw const ApiException('The API returned an invalid water schedule.');
    }

    final items = decoded
        .map((entry) =>
            WaterScheduleItem.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList();
    items.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    return items;
  }

  Future<WaterScheduleItem> updateSchedule({
    required int id,
    required String time,
    required String status,
  }) async {
    final decoded = await _api.put(
      '/api/water-schedule/$id',
      auth: true,
      body: {'time': time.trim(), 'status': status},
    );
    return WaterScheduleItem.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  void dispose() => _api.dispose();
}
