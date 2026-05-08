import 'dart:async';
import 'socket_service.dart';
import 'pairing_service.dart';

enum SyncEventType { heartbeat, moodUpdate, watching, presence, typing, pulse }

class SyncEvent {
  final SyncEventType type;
  final String senderId;
  final dynamic data;
  final DateTime timestamp;

  SyncEvent({
    required this.type,
    required this.senderId,
    this.data,
    required this.timestamp,
  });
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  
  final SocketService _socketService = SocketService();
  final PairingService _pairingService = PairingService();

  SyncService._internal() {
    _listenToSocket();
  }

  final _eventController = StreamController<SyncEvent>.broadcast();
  Stream<SyncEvent> get eventStream => _eventController.stream;

  void _listenToSocket() {
    _socketService.socketStream.listen((data) {
      final typeStr = data['type'] as String;
      final type = SyncEventType.values.firstWhere((e) => e.name == typeStr);
      
      _eventController.add(SyncEvent(
        type: type,
        senderId: data['senderId'],
        data: data['data'],
        timestamp: DateTime.now(),
      ));
    });
  }

  void sendEvent(SyncEventType type, {dynamic data}) {
    final roomId = _pairingService.generatedCode ?? 'rel_123';
    _socketService.emitEvent(roomId, type.name, data);
    
    // Also emit locally so the sender's UI can react if needed
    _eventController.add(SyncEvent(
      type: type,
      senderId: 'me',
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  void dispose() {
    _eventController.close();
  }
}
