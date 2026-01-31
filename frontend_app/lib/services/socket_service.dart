import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class SocketService extends ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  DateTime? _lastUpdate;
  
  bool get isConnected => _isConnected;
  DateTime? get lastUpdate => _lastUpdate;

  void connect() {
    try {
      _socket = IO.io(
        ApiConfig.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build()
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        debugPrint('✅ Socket connected!');
        _isConnected = true;
        notifyListeners();
      });

      _socket!.onDisconnect((_) {
        debugPrint('❌ Socket disconnected');
        _isConnected = false;
        notifyListeners();
      });

      _socket!.onError((error) {
        debugPrint('Socket error: $error');
      });

      // Listen for trend updates
      _socket!.on('trends:updated', (data) {
        debugPrint('⚡ Quick trends update: $data');
        _lastUpdate = DateTime.now();
        notifyListeners();
      });

      _socket!.on('trends:fullUpdate', (data) {
        debugPrint('🔄 Full trends update: $data');
        _lastUpdate = DateTime.now();
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Socket connection error: $e');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
    notifyListeners();
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
