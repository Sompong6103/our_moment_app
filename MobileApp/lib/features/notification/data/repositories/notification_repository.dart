import '../../../../core/services/api_client.dart';
import '../../domain/models/notification_model.dart';

class NotificationRepository {
  final _api = ApiClient();

  Future<List<NotificationModel>> list() async {
    final data = await _api.getList('/notifications', auth: true);
    return data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markRead(String notificationId) async {
    await _api.patch('/notifications/$notificationId/read', auth: true);
  }
}
