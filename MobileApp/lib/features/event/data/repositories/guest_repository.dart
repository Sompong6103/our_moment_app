import '../../../../core/services/api_client.dart';

class GuestRepository {
  final _api = ApiClient();

  Future<List<Map<String, dynamic>>> list(String eventId) async {
    final data = await _api.getList('/events/$eventId/guests', auth: true);
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> join(String eventId, {
    String? allergies,
    String? wish,
    int followersCount = 1,
  }) async {
    final body = <String, dynamic>{
      'followersCount': followersCount,
    };
    if (allergies != null && allergies.isNotEmpty) body['allergies'] = allergies;
    if (wish != null && wish.isNotEmpty) body['wish'] = wish;

    return await _api.post('/events/$eventId/guests/join', body: body, auth: true);
  }

  Future<Map<String, dynamic>> checkIn(String eventId) async {
    return await _api.post('/events/$eventId/guests/check-in', auth: true);
  }

  Future<Map<String, dynamic>> getMyStatus(String eventId) async {
    return await _api.get('/events/$eventId/guests/my-status', auth: true);
  }

  Future<Map<String, dynamic>> getDetail(String eventId, String guestId) async {
    return await _api.get('/events/$eventId/guests/$guestId', auth: true);
  }
}
