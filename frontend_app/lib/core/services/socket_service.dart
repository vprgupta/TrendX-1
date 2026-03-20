import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../config/api_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  final List<Function(Map<String, dynamic>)> _trendListeners = [];
  
  // Chat specific listeners
  final List<Function(Map<String, dynamic>)> _chatListeners = [];
  final List<Function(List<dynamic>)> _historyListeners = [];
  final List<Function(Map<String, dynamic>)> _typingListeners = [];

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

    // Chat events
    _socket!.on('receive_message', (data) {
      for (var listener in _chatListeners) {
        listener(data);
      }
    });

    _socket!.on('chat_history', (data) {
      for (var listener in _historyListeners) {
        listener(data);
      }
    });

    _socket!.on('typing_status', (data) {
      for (var listener in _typingListeners) {
        listener(data);
      }
    });
  }

  // --- Trend Listeners ---
  void addTrendListener(Function(Map<String, dynamic>) listener) {
    _trendListeners.add(listener);
  }

  void removeTrendListener(Function(Map<String, dynamic>) listener) {
    _trendListeners.remove(listener);
  }

  // --- Chat Room Methods ---
  void joinChat(String trendId, String userName) {
    if (_socket?.connected == true) {
      _socket!.emit('join_chat', {'trendId': trendId, 'userName': userName});
    }
  }

  void leaveChat(String trendId) {
    if (_socket?.connected == true) {
      _socket!.emit('leave_chat', {'trendId': trendId});
    }
  }

  void sendMessage(String trendId, String text, String senderName) {
    if (_socket?.connected == true) {
      _socket!.emit('send_message', {
        'trendId': trendId,
        'text': text,
        'senderName': senderName,
      });
    }
  }

  void startTyping(String trendId, String userName) {
    if (_socket?.connected == true) {
      _socket!.emit('typing_start', {'trendId': trendId, 'userName': userName});
    }
  }

  void stopTyping(String trendId, String userName) {
    if (_socket?.connected == true) {
      _socket!.emit('typing_end', {'trendId': trendId, 'userName': userName});
    }
  }

  // --- Chat Listeners ---
  void addChatListener(Function(Map<String, dynamic>) listener) => _chatListeners.add(listener);
  void removeChatListener(Function(Map<String, dynamic>) listener) => _chatListeners.remove(listener);

  void addHistoryListener(Function(List<dynamic>) listener) => _historyListeners.add(listener);
  void removeHistoryListener(Function(List<dynamic>) listener) => _historyListeners.remove(listener);

  void addTypingListener(Function(Map<String, dynamic>) listener) => _typingListeners.add(listener);
  void removeTypingListener(Function(Map<String, dynamic>) listener) => _typingListeners.remove(listener);

  void disconnect() {
    _socket?.disconnect();
  }
}