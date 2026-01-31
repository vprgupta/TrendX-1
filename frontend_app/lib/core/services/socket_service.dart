import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../config/api_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  final List<Function(Map<String, dynamic>)> _trendListeners = [];

  void connect() {
    _socket = io.io(ApiConfig.serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();
    
    _socket!.on('connect', (_) {
      print('Connected to server');
    });

    _socket!.on('trendCreated', (data) {
      for (var listener in _trendListeners) {
        listener({'type': 'created', 'data': data});
      }
    });

    _socket!.on('trendDeleted', (data) {
      for (var listener in _trendListeners) {
        listener({'type': 'deleted', 'data': data});
      }
    });
  }

  void addTrendListener(Function(Map<String, dynamic>) listener) {
    _trendListeners.add(listener);
  }

  void removeTrendListener(Function(Map<String, dynamic>) listener) {
    _trendListeners.remove(listener);
  }

  void disconnect() {
    _socket?.disconnect();
  }
}