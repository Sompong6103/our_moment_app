import '../../../../core/services/api_client.dart';

class WishRepository {
  final _api = ApiClient();

  Future<List<Map<String, dynamic>>> list(String eventId) async {
    final data = await _api.getList('/events/$eventId/wishes', auth: true);
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create(String eventId, String message) async {
    return await _api.post('/events/$eventId/wishes', body: {
      'message': message,
    }, auth: true);
  }

  Future<void> delete(String eventId, String wishId) async {
    await _api.delete('/events/$eventId/wishes/$wishId', auth: true);
  }
}
