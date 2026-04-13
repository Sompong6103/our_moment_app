class ApiConfig {
  // สำหรับ Android Emulator ใช้ 10.0.2.2 แทน localhost
  // สำหรับ iOS Simulator ใช้ localhost ได้เลย
  // สำหรับ real device ใช้ IP ของเครื่อง backend
  static const String host = '192.168.1.102';
  static const String baseUrl = 'http://$host:3000/api';
  static String get uploadsUrl => baseUrl.replaceAll('/api', '/uploads');

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
