import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_config.dart';
import 'token_storage.dart';

class SocketService {
  static final SocketService _instance = SocketService._();
  factory SocketService() => _instance;
  SocketService._();

  io.Socket? _socket;
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onNotification => _notificationController.stream;

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await TokenStorage().getAccessToken();
    if (token == null) return;

    final serverUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Socket connected');
    });

    _socket!.on('notification', (data) {
      debugPrint('Socket notification received: $data');
      if (data is Map<String, dynamic>) {
        _notificationController.add(data);
      } else if (data is Map) {
        _notificationController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket disconnected');
    });

    _socket!.onConnectError((err) {
      debugPrint('Socket connect error: $err');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
