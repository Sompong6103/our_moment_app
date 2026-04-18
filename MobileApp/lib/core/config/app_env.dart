/// App environment configuration.
/// Values are injected at build time via --dart-define or --dart-define-from-file.
///
/// Usage:
///   flutter run --dart-define-from-file=env/dev.env
///   flutter build ios --dart-define-from-file=env/prod.env
class AppEnv {
  AppEnv._();

  // Server — API_HOST includes port when needed (e.g. 192.168.1.102:3000)
  static const String apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '192.168.1.102:3000',
  );
  static const String apiScheme = String.fromEnvironment(
    'API_SCHEME',
    defaultValue: 'http',
  );

  // Google OAuth
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  // Derived URLs
  static String get baseUrl => '$apiScheme://$apiHost/api';
  static String get serverUrl => '$apiScheme://$apiHost';
  static String get uploadsUrl => '$apiScheme://$apiHost/uploads';
}
