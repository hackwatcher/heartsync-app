import 'dart:async';
import 'dart:math';
import '../models/sync_models.dart';
import 'persistence_service.dart';
import 'socket_service.dart';
import 'app_state.dart';

enum PairingStatus { idle, waiting, connecting, connected, error }

class PairingService {
  static final PairingService _instance = PairingService._internal();
  factory PairingService() => _instance;
  PairingService._internal();

  final PersistenceService _persistenceService = PersistenceService();
  final SocketService _socketService = SocketService();
  final AppState _appState = AppState();

  final _statusController = StreamController<PairingStatus>.broadcast();
  Stream<PairingStatus> get statusStream => _statusController.stream;

  HSRelationship? _currentRelationship;
  HSRelationship? get relationship => _currentRelationship;

  String? _generatedCode;
  String? get generatedCode => _generatedCode;
  
  StreamSubscription? _listenSub;

  /// Tries to load existing pairing from local storage
  Future<bool> tryAutoConnect() async {
    final savedRel = await _persistenceService.getObject('hs_relationship');
    if (savedRel != null) {
      final roomId = savedRel['id'] as String? ?? 'rel_123';
      _currentRelationship = HSRelationship(
        id: roomId,
        partner1Id: 'me',
        partner2Id: _appState.partnerName,
        startDate: DateTime(2024, 1, 1),
        nextMeetingDate: _appState.reunionDate,
      );
      _socketService.connect();
      _socketService.joinRoom(roomId);
      _statusController.add(PairingStatus.connected);
      return true;
    }
    return false;
  }

  /// Generates a new 8-digit pairing code
  String generateNewCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    _generatedCode = String.fromCharCodes(Iterable.generate(
      8, (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));

    _socketService.connect();
    _socketService.joinRoom(_generatedCode!);
    _statusController.add(PairingStatus.waiting);
    
    // Set room immediately so UI transitions
    _appState.setConnected(true, room: _generatedCode);

    _listenSub?.cancel();
    // Listen for partner joining/leaving (real-time relay)
    _listenSub = _socketService.socketStream.listen((event) {
      if (event['type'] == 'pair_connected' || 
          (event['type'] == 'partner_online' && event['count'] >= 2) ||
          event['type'] == 'presence' || 
          event['type'] == 'room_joined') {
        _statusController.add(PairingStatus.connected);
        _persistenceService.saveObject('hs_relationship', {'id': _generatedCode, 'connected': true});
        _appState.setConnected(true, room: _generatedCode);
      } else if (event['type'] == 'partner_disconnected') {
        _statusController.add(PairingStatus.waiting);
        _appState.setConnected(false); // Disconnected visually but keep room
      }
    });

    return _generatedCode!;
  }

  /// Connects to a partner with a code
  Future<bool> connectWithCode(String code) async {
    _statusController.add(PairingStatus.connecting);

    _socketService.connect();
    
    // Join the room instantly
    _socketService.joinRoom(code);
    
    // Save the room to persistence so they can enter the app immediately
    await _persistenceService.saveObject('hs_relationship', {'id': code, 'connected': true});
    await _appState.setConnected(true, room: code);
    
    _statusController.add(PairingStatus.connected);
    return true;
  }

  Future<void> reset() async {
    _generatedCode = null;
    _currentRelationship = null;
    _listenSub?.cancel();
    await _persistenceService.remove('hs_relationship');
    await _appState.disconnect();
    _statusController.add(PairingStatus.idle);
  }

  void dispose() {
    _listenSub?.cancel();
    _statusController.close();
  }
}
