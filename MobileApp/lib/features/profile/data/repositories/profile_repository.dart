import '../../../../core/services/api_client.dart';
import '../../domain/models/profile_model.dart';

class ProfileRepository {
  final _api = ApiClient();

  Future<ProfileModel> getProfile() async {
    final data = await _api.get('/users/profile', auth: true);
    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? gender,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    if (gender != null) body['gender'] = gender;

    final data = await _api.patch('/users/profile', body: body, auth: true);
    return ProfileModel.fromJson(data);
  }

  Future<void> uploadAvatar(String filePath) async {
    await _api.uploadFile(
      '/users/avatar',
      filePath: filePath,
      fieldName: 'avatar',
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    await _api.patch('/users/password', body: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    }, auth: true);
  }
}
