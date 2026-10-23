import '../../core/network/api_client.dart';
import '../models/contact_model.dart';

class ContactsRepository {
  ContactsRepository({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<List<CommunityContact>> fetchContacts({String? category}) async {
    final query = category == null
        ? ''
        : '?category=${Uri.encodeQueryComponent(category)}';
    final decoded = await _api.get('/api/contacts$query');
    if (decoded is! List) {
      throw const ApiException('The API returned invalid contacts.');
    }
    return decoded
        .map((e) =>
            CommunityContact.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<CommunityContact> create(CommunityContact contact) async {
    final decoded = await _api.post('/api/admin/contacts',
        auth: true, body: contact.toRequestJson());
    return CommunityContact.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  Future<CommunityContact> update(CommunityContact contact) async {
    final decoded = await _api.put('/api/admin/contacts/${contact.id}',
        auth: true, body: contact.toRequestJson());
    return CommunityContact.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  Future<void> delete(int id) =>
      _api.delete('/api/admin/contacts/$id', auth: true);
}
