import '../../core/network/api_client.dart';
import '../models/gym_schedule_model.dart';

class GymRepository {
  GymRepository({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<List<GymSession>> fetchSessions() async {
    final decoded = await _api.get('/api/gym-sessions');
    if (decoded is! List) {
      throw const ApiException('The API returned invalid gym sessions.');
    }
    return decoded
        .map((e) => GymSession.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<GymSession> create(GymSession session) async {
    final decoded = await _api.post('/api/admin/gym-sessions',
        auth: true, body: session.toRequestJson());
    return GymSession.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  Future<GymSession> update(GymSession session) async {
    final decoded = await _api.put('/api/admin/gym-sessions/${session.id}',
        auth: true, body: session.toRequestJson());
    return GymSession.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  Future<void> delete(int id) =>
      _api.delete('/api/admin/gym-sessions/$id', auth: true);
}
