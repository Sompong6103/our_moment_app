import '../config/app_env.dart';

class ApiConfig {
  static String get host => AppEnv.apiHost;
  static String get baseUrl => AppEnv.baseUrl;
  static String get uploadsUrl => AppEnv.uploadsUrl;
  static String get serverUrl => AppEnv.serverUrl;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Resolve a relative file path to a full URL.
  /// Returns null if the input is null or empty.
  static String? fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '$uploadsUrl/$url';
  }
}
