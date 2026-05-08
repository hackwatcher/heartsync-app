import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ConnectionState { disconnected, connecting, connected, error }

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get socketStream => _eventController.stream;

  final _connectionController = StreamController<ConnectionState>.broadcast();
  Stream<ConnectionState> get connectionStream => _connectionController.stream;

  ConnectionState _state = ConnectionState.disconnected;
  ConnectionState get state => _state;

  String? _lastError;
  String? get lastError => _lastError;

  static const String _productionUrl = 'https://heartsync-server-oe8w.onrender.com';


  String? _pendingRoomId;

  void connect({String? serverUrl}) {
    // ALWAYS use production url to avoid localhost issue on phones
    final url = serverUrl ?? _productionUrl;
    
    if (socket?.connected == true) return;

    _setState(ConnectionState.connecting);

    socket = IO.io(url,
      IO.OptionBuilder()
        .enableAutoConnect()
        .setTimeout(20000) // 20 seconds connection timeout
        .setReconnectionAttempts(99999) // Infinite retries for network drops/cellular switching
        .setReconnectionDelay(2000) // Retry every 2 seconds
        .build()
    );

    socket!.onConnect((_) {
      _lastError = null;
      _setState(ConnectionState.connected);
      if (_pendingRoomId != null) {
        socket!.emit('join_room', _pendingRoomId);
      }
    });

    // Listen to ALL events, not just sync_event
    socket!.onAny((event, data) {
      if (data is Map) {
        if (event == 'sync_event') {
          // Wrapped events like webrtc_offer
          _eventController.add(Map<String, dynamic>.from(data));
        } else {
          // Direct server events like pair_connected
          final payload = Map<String, dynamic>.from(data);
          payload['type'] ??= event; 
          _eventController.add(payload);
        }
      }
    });

    socket!.onDisconnect((_) {
      _setState(ConnectionState.disconnected);
    });

    socket!.onConnectError((err) {
      _lastError = 'Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.';
      _setState(ConnectionState.error);
    });

    socket!.onError((err) {
      _lastError = err.toString();
      _setState(ConnectionState.error);
    });
  }

  void _setState(ConnectionState state) {
    _state = state;
    _connectionController.add(state);
  }

  void joinRoom(String roomId) {
    _pendingRoomId = roomId;
    if (socket?.connected == true) {
      socket!.emit('join_room', roomId);
    }
  }

  void emitEvent(String roomId, String type, dynamic data) {
    if (socket?.connected == true) {
      socket!.emit('sync_event', {
        'roomId': roomId,
        'type': type,
        'data': data,
        'senderId': 'user_${socket?.id ?? "local"}',
      });
    }
  }

  bool get isConnected => socket?.connected == true;

  void dispose() {
    socket?.dispose();
    _eventController.close();
    _connectionController.close();
  }
}
