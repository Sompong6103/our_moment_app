class ApiConfig {
  // สำหรับ Android Emulator ใช้ 10.0.2.2 แทน localhost
  // สำหรับ iOS Simulator ใช้ localhost ได้เลย
  // สำหรับ real device ใช้ IP ของเครื่อง backend
  static const String baseUrl = 'http://localhost:3000/api';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
