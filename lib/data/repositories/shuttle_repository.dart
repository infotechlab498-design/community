import '../../core/network/api_client.dart';
import '../models/shuttle_route_model.dart';

class ShuttleRepository {
  ShuttleRepository({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<List<ShuttleRoute>> fetchRoutes() async {
    final decoded = await _api.get('/api/shuttle');
    if (decoded is! List) {
      throw const ApiException('The API returned an invalid shuttle schedule.');
    }
    return decoded
        .map((e) => ShuttleRoute.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Replaces every departure on [routeId]; [times] are "HH:mm".
  Future<ShuttleRoute> saveRoute({
    required String routeId,
    required String origin,
    required String destination,
    required List<String> times,
  }) async {
    final decoded = await _api.put(
      '/api/admin/shuttle/${Uri.encodeComponent(routeId)}',
      auth: true,
      body: {'origin': origin, 'destination': destination, 'times': times},
    );
    return ShuttleRoute.fromJson(Map<String, dynamic>.from(decoded as Map));
  }
}
