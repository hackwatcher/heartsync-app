import 'dart:async';
import 'socket_service.dart';
import 'app_state.dart';

enum WatchEventType { play, pause, seek, changeVideo, buffer }

class WatchEvent {
  final WatchEventType type;
  final Duration position;
  final String? videoUrl;
  final String senderId;

  WatchEvent({
    required this.type,
    required this.position,
    this.videoUrl,
    required this.senderId,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'position': position.inSeconds,
    'videoUrl': videoUrl,
  };
}

class WatchService {
  static final WatchService _instance = WatchService._internal();
  factory WatchService() => _instance;
  WatchService._internal();

  final SocketService _socketService = SocketService();
  final AppState _appState = AppState();

  final _watchEventController = StreamController<WatchEvent>.broadcast();
  Stream<WatchEvent> get watchEventStream => _watchEventController.stream;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;

  void init() {
    _socketService.socketStream.listen((event) {
      // 1. Initial State Sync (Snapshot)
      if (event['type'] == 'sync_snapshot') {
        _isPlaying = event['isPlaying'] == true;
        _currentPosition = Duration(milliseconds: event['videoTime'] ?? 0);
        
        // If playing, calculate elapsed time since snapshot was taken
        if (_isPlaying && event['lastUpdatedAt'] != null) {
          final serverNow = DateTime.now().millisecondsSinceEpoch;
          final elapsed = serverNow - (event['lastUpdatedAt'] as int);
          if (elapsed > 0) {
            _currentPosition += Duration(milliseconds: elapsed);
          }
        }

          _watchEventController.add(WatchEvent(
            type: _isPlaying ? WatchEventType.play : WatchEventType.pause,
            position: _currentPosition,
            senderId: 'server_snapshot',
          ));
        }

        if (event['type'] == 'watch_sync_request') {
          // Handled in UI layer via watchEventStream if needed or directly here
          // But usually we want the UI to provide the exact video position
          _watchEventController.add(WatchEvent(
            type: WatchEventType.buffer, // Use buffer as a signal for "sync requested"
            position: Duration.zero,
            senderId: event['senderId'],
          ));
        }
      
      // 2. Real-time Events
      if (event['type'] == 'watch_command') {
        final data = event['data'];
        final action = data['action'];
        final targetPosition = Duration(milliseconds: data['timestamp']);
        
        bool requiresHardSeek = false;
        
        if (action == 'play') {
          _isPlaying = true;
          // Drift Correction on Play
          if ((_currentPosition - targetPosition).inMilliseconds.abs() > 500) {
            requiresHardSeek = true;
          }
        } else if (action == 'pause' || action == 'buffer') {
          _isPlaying = false;
          requiresHardSeek = true; // Always sync exact frame on pause
        } else if (action == 'seek') {
          requiresHardSeek = true;
        }

        if (requiresHardSeek) {
          _currentPosition = targetPosition;
        }

        final watchEvent = WatchEvent(
          type: action == 'play' ? WatchEventType.play 
              : action == 'pause' ? WatchEventType.pause 
              : action == 'changeVideo' ? WatchEventType.changeVideo
              : action == 'buffer' ? WatchEventType.buffer
              : WatchEventType.seek,
          position: _currentPosition,
          videoUrl: data['videoUrl'],
          senderId: event['senderId'],
        );
        _watchEventController.add(watchEvent);
      }
    });
  }

  void emitEvent(String roomId, String type, dynamic data) {
    _socketService.emitEvent(roomId, type, data);
  }

  void requestSync(String roomId) {
    _socketService.emitEvent(roomId, 'watch_sync_request', {'timestamp': DateTime.now().millisecondsSinceEpoch});
  }

  void sendSyncSnapshot(String roomId, bool isPlaying, Duration position) {
    _socketService.emitEvent(roomId, 'sync_snapshot', {
      'isPlaying': isPlaying,
      'videoTime': position.inMilliseconds,
      'lastUpdatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Sends a sync command to the partner via Socket
  void sendCommand(WatchEventType type, Duration position, {String? videoUrl}) {
    _isPlaying = type == WatchEventType.play;
    _currentPosition = position;

    _socketService.emitEvent(
      _appState.roomId ?? 'default', 
      'watch_command', 
      {
        'action': type.name, // 'play', 'pause', 'seek'
        'timestamp': position.inMilliseconds,
        'videoUrl': videoUrl,
      }
    );
  }
}
