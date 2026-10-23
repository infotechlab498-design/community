import '../../core/network/api_client.dart';
import '../models/hospital_model.dart';

class HospitalsRepository {
  HospitalsRepository({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<List<Hospital>> fetchHospitals() async {
    final decoded = await _api.get('/api/hospitals');
    if (decoded is! List) {
      throw const ApiException('The API returned invalid hospitals.');
    }
    return decoded
        .map((e) => Hospital.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Hospital> create(Hospital hospital) async {
    final decoded = await _api.post('/api/admin/hospitals',
        auth: true, body: hospital.toRequestJson());
    return Hospital.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  Future<Hospital> update(Hospital hospital) async {
    final decoded = await _api.put('/api/admin/hospitals/${hospital.id}',
        auth: true, body: hospital.toRequestJson());
    return Hospital.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  Future<void> delete(int id) =>
      _api.delete('/api/admin/hospitals/$id', auth: true);
}
