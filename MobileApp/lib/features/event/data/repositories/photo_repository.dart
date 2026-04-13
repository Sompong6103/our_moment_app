import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/services/api_client.dart';
import '../../../../core/services/api_config.dart';
import '../../../../core/services/token_storage.dart';
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

  Future<List<GalleryPhoto>> searchByFace(String eventId, String selfiePath) async {
    final tokenStorage = TokenStorage();
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/events/$eventId/photos/face-search');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('selfie', selfiePath));

    final streamedResponse = await request.send().timeout(ApiConfig.receiveTimeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, 'Face search failed');
    }

    final decoded = jsonDecode(response.body);
    final list = decoded is List ? decoded : <dynamic>[];
    return list
        .map((e) => GalleryPhoto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
