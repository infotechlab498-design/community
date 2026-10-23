import '../../core/network/api_client.dart';
import '../models/water_supply_model.dart';

class WaterSupplyRepository {
  WaterSupplyRepository({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<List<WaterBlock>> fetchBlocks() async {
    final decoded = await _api.get('/api/water-supply/blocks');
    if (decoded is! List) {
      throw const ApiException('The API returned invalid water blocks.');
    }
    return decoded
        .map((e) => WaterBlock(
              id: (e as Map)['id'] as String,
              name: e['name'] as String,
            ))
        .toList();
  }

  /// Published month for residents, or null when nothing is published yet.
  Future<WaterSupplyMonth?> fetchPublishedMonth(int year, int month) async {
    try {
      final decoded =
          await _api.get('/api/water-supply/month?year=$year&month=$month');
      return WaterSupplyMonth.fromJson(Map<String, dynamic>.from(decoded as Map));
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  /// Admin view including drafts, or null when the month has no schedule yet.
  Future<WaterSupplyMonth?> fetchAdminMonth(int year, int month) async {
    try {
      final decoded = await _api.get(
          '/api/admin/water-supply?year=$year&month=$month',
          auth: true);
      return WaterSupplyMonth.fromJson(Map<String, dynamic>.from(decoded as Map));
    } on ApiException catch (e) {
      if (e is! SessionExpiredException && e.isNotFound) return null;
      rethrow;
    }
  }

  Future<void> saveDraft(WaterSupplyMonth month) => _api.put(
        '/api/admin/water-supply?year=${month.year}&month=${month.month}',
        auth: true,
        body: month.toSaveRequestJson(),
      );

  Future<void> publish(int year, int month) => _api.post(
        '/api/admin/water-supply/publish',
        auth: true,
        body: {'year': year, 'month': month},
      );

  Future<void> unpublish(int year, int month) => _api.post(
        '/api/admin/water-supply/unpublish',
        auth: true,
        body: {'year': year, 'month': month},
      );
}
