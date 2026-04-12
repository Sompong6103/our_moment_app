import '../../../../core/services/api_client.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/agenda_item.dart';

class EventRepository {
  final _api = ApiClient();

  Future<Map<String, List<EventModel>>> listMyEvents() async {
    final data = await _api.get('/events', auth: true);

    final organized = (data['organized'] as List? ?? [])
        .map((e) => EventModel.fromJson({...e as Map<String, dynamic>, '_isHost': true}))
        .toList();

    final joined = (data['joined'] as List? ?? [])
        .map((e) => EventModel.fromJson({...e as Map<String, dynamic>, '_isJoined': true}))
        .toList();

    return {'organized': organized, 'joined': joined};
  }

  Future<EventModel> getById(String eventId) async {
    final data = await _api.get('/events/$eventId', auth: true);
    return EventModel.fromJson(data);
  }

  Future<EventModel> getByCode(String joinCode) async {
    final data = await _api.get('/events/code/$joinCode', auth: true);
    return EventModel.fromJson(data);
  }

  Future<EventModel> create({
    required String title,
    required String type,
    String? description,
    required String dateStart,
    required String dateEnd,
    String? themeName,
    String? themeColor,
    bool acceptPhotos = false,
    Map<String, dynamic>? location,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'type': type,
      'dateStart': dateStart,
      'dateEnd': dateEnd,
      'acceptPhotos': acceptPhotos,
    };
    if (description != null) body['description'] = description;
    if (themeName != null) body['themeName'] = themeName;
    if (themeColor != null) body['themeColor'] = themeColor;
    if (location != null) body['location'] = location;

    final data = await _api.post('/events', body: body, auth: true);
    return EventModel.fromJson(data);
  }

  Future<void> uploadCover(String eventId, String filePath) async {
    await _api.uploadFile(
      '/events/$eventId/cover',
      filePath: filePath,
      fieldName: 'cover',
    );
  }

  Future<List<AgendaItem>> getAgenda(String eventId) async {
    final items = await _api.getList('/events/$eventId/agenda', auth: true);
    return items.map((e) => AgendaItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createAgendaItem(String eventId, {
    required String title,
    String? description,
    String? location,
    required String startTime,
    String? endTime,
    int? sortOrder,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'dateTime': startTime,
    };
    if (description != null) body['description'] = description;
    if (location != null) body['location'] = location;
    if (sortOrder != null) body['sortOrder'] = sortOrder;

    await _api.post('/events/$eventId/agenda', body: body, auth: true);
  }

  Future<Map<String, dynamic>> getAnalytics(String eventId) async {
    return await _api.get('/events/$eventId/analytics', auth: true);
  }

  Future<List<Map<String, dynamic>>> getTopContributors(String eventId) async {
    final data = await _api.getList('/events/$eventId/analytics/top-contributors', auth: true);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> updateAgendaItem(String eventId, String itemId, {
    required String title,
    String? description,
    String? location,
    required String startTime,
    int? sortOrder,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'dateTime': startTime,
    };
    if (description != null) body['description'] = description;
    if (location != null) body['location'] = location;
    if (sortOrder != null) body['sortOrder'] = sortOrder;

    await _api.patch('/events/$eventId/agenda/$itemId', body: body, auth: true);
  }

  Future<void> deleteAgendaItem(String eventId, String itemId) async {
    await _api.delete('/events/$eventId/agenda/$itemId', auth: true);
  }

  Future<void> delete(String eventId) async {
    await _api.delete('/events/$eventId', auth: true);
  }

  Future<EventModel> update(String eventId, Map<String, dynamic> data) async {
    final result = await _api.patch('/events/$eventId', body: data, auth: true);
    return EventModel.fromJson(result);
  }
}
