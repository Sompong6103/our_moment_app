import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  final _client = http.Client();
  final _tokenStorage = TokenStorage();

  Map<String, String> _headers({bool auth = false, String? token}) {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    if (auth && token != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    return _request('POST', path, body: body, auth: auth);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    bool auth = false,
  }) async {
    return _request('GET', path, queryParams: queryParams, auth: auth);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? queryParams,
    bool auth = false,
  }) async {
    return _requestList('GET', path, queryParams: queryParams, auth: auth);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    return _request('PATCH', path, body: body, auth: auth);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = false,
  }) async {
    return _request('DELETE', path, auth: auth);
  }

  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, String>? fields,
    bool auth = true,
  }) async {
    String? token;
    if (auth) {
      token = await _tokenStorage.getAccessToken();
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    if (fields != null) request.fields.addAll(fields);

    try {
      final streamedResponse = await request.send().timeout(ApiConfig.receiveTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 401 && auth) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return uploadFile(path, filePath: filePath, fieldName: fieldName, fields: fields, auth: auth);
        }
      }

      if (response.statusCode >= 400) {
        throw ApiException(response.statusCode, data['error'] ?? 'Upload failed');
      }
      return data;
    } on SocketException {
      throw ApiException(0, 'Cannot connect to server');
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool auth = false,
  }) async {
    String? token;
    if (auth) {
      token = await _tokenStorage.getAccessToken();
    }

    var uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    http.Response response;

    try {
      switch (method) {
        case 'POST':
          response = await _client
              .post(uri, headers: _headers(auth: auth, token: token), body: jsonEncode(body))
              .timeout(ApiConfig.connectTimeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(uri, headers: _headers(auth: auth, token: token), body: jsonEncode(body))
              .timeout(ApiConfig.connectTimeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: _headers(auth: auth, token: token))
              .timeout(ApiConfig.connectTimeout);
          break;
        default:
          response = await _client
              .get(uri, headers: _headers(auth: auth, token: token))
              .timeout(ApiConfig.connectTimeout);
      }
    } on SocketException {
      throw ApiException(0, 'Cannot connect to server');
    } on HttpException {
      throw ApiException(0, 'Connection error');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Auto refresh token on 401
    if (response.statusCode == 401 && auth) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return _request(method, path, body: body, queryParams: queryParams, auth: auth);
      }
    }

    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, data['error'] ?? 'Something went wrong');
    }

    return data;
  }

  Future<List<dynamic>> _requestList(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool auth = false,
  }) async {
    String? token;
    if (auth) {
      token = await _tokenStorage.getAccessToken();
    }

    var uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    http.Response response;
    try {
      response = await _client
          .get(uri, headers: _headers(auth: auth, token: token))
          .timeout(ApiConfig.connectTimeout);
    } on SocketException {
      throw ApiException(0, 'Cannot connect to server');
    } on HttpException {
      throw ApiException(0, 'Connection error');
    }

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 401 && auth) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return _requestList(method, path, body: body, queryParams: queryParams, auth: auth);
      }
    }

    if (response.statusCode >= 400) {
      final msg = decoded is Map ? decoded['error'] ?? 'Something went wrong' : 'Something went wrong';
      throw ApiException(response.statusCode, msg);
    }

    return decoded is List ? decoded : [];
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/refresh-token');
      final response = await _client.post(
        uri,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await _tokenStorage.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        return true;
      }
    } catch (_) {}

    await _tokenStorage.clearAll();
    return false;
  }
}
