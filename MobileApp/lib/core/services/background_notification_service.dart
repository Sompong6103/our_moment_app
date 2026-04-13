import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Background service that maintains a Socket.IO connection
/// and shows push-style notifications even when the app is closed.
class BackgroundNotificationService {
  static final BackgroundNotificationService _instance =
      BackgroundNotificationService._();
  factory BackgroundNotificationService() => _instance;
  BackgroundNotificationService._();

  static const _channelId = 'our_moment_foreground';
  static const _channelName = 'Our Moment Background';
  static const _pushChannelId = 'our_moment_push';
  static const _pushChannelName = 'Push Notifications';

  final _service = FlutterBackgroundService();

  Future<void> initialize() async {
    // Android foreground notification channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Keeps notification connection alive',
      importance: Importance.low,
    );

    final notifPlugin = FlutterLocalNotificationsPlugin();
    await notifPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Push notification channel
    const pushChannel = AndroidNotificationChannel(
      _pushChannelId,
      _pushChannelName,
      description: 'Event notifications and reminders',
      importance: Importance.high,
    );
    await notifPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(pushChannel);

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: true,
        autoStartOnBoot: true,
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'Our Moment',
        initialNotificationContent: 'Connected for notifications',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  Future<void> start() async {
    await _service.startService();
  }

  Future<void> stop() async {
    final svc = FlutterBackgroundService();
    svc.invoke('stopService');
  }
}

// ─── Background isolate entry points ───

@pragma('vm:entry-point')
Future<void> _onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Initialize local notifications for showing push
  final notifPlugin = FlutterLocalNotificationsPlugin();
  await notifPlugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  // Read token from secure storage
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final token = await storage.read(key: 'access_token');

  if (token == null) {
    debugPrint('[BG] No access token, stopping background service');
    await service.stopSelf();
    return;
  }

  // Connect Socket.IO
  const serverUrl = 'http://192.168.1.102:3000';
  final socket = io.io(
    serverUrl,
    io.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionDelay(5000)
        .setReconnectionAttempts(double.infinity.toInt())
        .build(),
  );

  socket.onConnect((_) {
    debugPrint('[BG] Socket connected');
  });

  socket.on('notification', (data) {
    debugPrint('[BG] Push notification received: $data');
    final map = data is Map<String, dynamic>
        ? data
        : Map<String, dynamic>.from(data as Map);

    final title = map['title'] as String? ?? 'Our Moment';
    final message = map['message'] as String? ?? '';

    notifPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: message,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'our_moment_push',
          'Push Notifications',
          channelDescription: 'Event notifications and reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  });

  socket.onDisconnect((_) {
    debugPrint('[BG] Socket disconnected');
  });

  socket.onConnectError((err) {
    debugPrint('[BG] Socket connect error: $err');
  });

  // Listen for stop command from the app
  service.on('stopService').listen((_) {
    debugPrint('[BG] Stopping background service');
    socket.disconnect();
    socket.dispose();
    service.stopSelf();
  });
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return true;
}
