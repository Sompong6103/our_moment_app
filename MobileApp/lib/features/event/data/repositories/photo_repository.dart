import '../../../../core/services/api_client.dart';
import '../../presentation/pages/photo_viewer_page.dart';

class PhotoRepository {
  final _api = ApiClient();

  Future<List<GalleryPhoto>> list(String eventId) async {
    final photos = await _api.getList('/events/$eventId/photos', auth: true);
    return photos.map((e) => GalleryPhoto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GalleryPhoto> upload(String eventId, String filePath) async {
    final data = await _api.uploadFile(
      '/events/$eventId/photos',
      filePath: filePath,
      fieldName: 'photo',
    );
    return GalleryPhoto.fromJson(data);
  }

  Future<void> delete(String eventId, String photoId) async {
    await _api.delete('/events/$eventId/photos/$photoId', auth: true);
  }
}
