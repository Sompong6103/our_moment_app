import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/token_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _api = ApiClient();
  final _tokenStorage = TokenStorage();
  static bool _googleInitialized = false;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });

    await _tokenStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
      userId: data['user']?['id'],
    );

    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final data = await _api.post('/auth/register', body: {
      'fullName': fullName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });

    await _tokenStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
      userId: data['user']?['id'],
    );

    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> googleSignIn() async {
    final gsi = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await gsi.initialize(
        clientId: '959978755059-ms5k2ebjgcvk5dib9t8v7r6au4c3aghv.apps.googleusercontent.com',
        serverClientId: '959978755059-7qanfth6claj62p97ml1n90og40e057k.apps.googleusercontent.com',
      );
      _googleInitialized = true;
    }

    final account = await gsi.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) throw Exception('Failed to get Google ID token');

    final data = await _api.post('/auth/google', body: {
      'idToken': idToken,
    });

    await _tokenStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
      userId: data['user']?['id'],
    );

    return UserModel.fromJson(data['user']);
  }

  Future<void> forgotPassword(String email) async {
    await _api.post('/auth/forgot-password', body: {'email': email});
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _api.post('/auth/logout', body: {'refreshToken': refreshToken});
      }
    } catch (e) {
      debugPrint('Logout API error: $e');
    }
    await _tokenStorage.clearAll();
  }

  Future<bool> isLoggedIn() => _tokenStorage.hasTokens();

  Future<UserModel> getProfile() async {
    final data = await _api.get('/users/profile', auth: true);
    return UserModel.fromJson(data);
  }
}
