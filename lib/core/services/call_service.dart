import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'socket_service.dart';
import 'app_state.dart';

enum CallStatus { idle, calling, connected, ended, incoming }

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final SocketService _socketService = SocketService();
  final AppState _appState = AppState();

  final _statusController = StreamController<CallStatus>.broadcast();
  Stream<CallStatus> get statusStream => _statusController.stream;
  
  // Incoming call notification stream
  final _incomingCallController = StreamController<bool>.broadcast();
  Stream<bool> get incomingCallStream => _incomingCallController.stream;
  
  CallStatus _currentStatus = CallStatus.idle;
  CallStatus get currentStatus => _currentStatus;

  RTCPeerConnection? _peerConnection;
  RTCVideoRenderer? localRenderer;
  RTCVideoRenderer? remoteRenderer;
  MediaStream? _localStream;
  
  bool _isMuted = false;
  bool get isMuted => _isMuted;
  set isMuted(bool val) {
    _isMuted = val;
    if (_localStream != null) {
      for (var track in _localStream!.getAudioTracks()) {
        track.enabled = !val;
      }
    }
    _statusController.add(_currentStatus);
  }

  bool _isCameraOff = false;
  bool get isCameraOff => _isCameraOff;
  set isCameraOff(bool val) {
    _isCameraOff = val;
    if (_localStream != null) {
      for (var track in _localStream!.getVideoTracks()) {
        track.enabled = !val;
      }
    }
    _statusController.add(_currentStatus);
  }

  double remoteVolume = 1.0; // UI state representation

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  Future<void> initRenderers() async {
    localRenderer = RTCVideoRenderer();
    remoteRenderer = RTCVideoRenderer();
    await localRenderer!.initialize();
    await remoteRenderer!.initialize();
    
    // Listen to signaling events from socket
    _socketService.socketStream.listen(_handleSignalingEvent);
  }

  RTCSessionDescription? _pendingOffer;
  RTCSessionDescription? get pendingOffer => _pendingOffer;

  void _handleSignalingEvent(Map<String, dynamic> event) async {
    final type = event['type'];
    final data = event['data'];

    if (type == 'webrtc_offer') {
      _currentStatus = CallStatus.incoming;
      _pendingOffer = RTCSessionDescription(data['sdp'], data['type']);
      _statusController.add(_currentStatus);
      _incomingCallController.add(true); // Show incoming call screen
    } else if (type == 'webrtc_answer') {
      await _handleAnswer(data);
    } else if (type == 'webrtc_ice_candidate') {
      await _handleIceCandidate(data);
    } else if (type == 'webrtc_end') {
      _incomingCallController.add(false);
      await endCall(notifyPartner: false);
    }
  }
  
  // Called when user accepts the incoming call
  Future<void> acceptCall(RTCSessionDescription offer) async {
    _incomingCallController.add(false);
    await _handleOffer(offer.toMap());
  }
  


  Future<void> startCall([String? roomId]) async {
    final room = roomId ?? _appState.roomId ?? 'default';
    _currentStatus = CallStatus.calling;
    _statusController.add(_currentStatus);

    await _createPeerConnection(room);
    
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _socketService.emitEvent(room, 'webrtc_offer', offer.toMap());
  }

  Future<void> _handleOffer(Map<String, dynamic> offerData) async {
    _storeOffer(offerData);
    final room = _appState.roomId ?? 'default';
    await _createPeerConnection(room);
    
    RTCSessionDescription offer = RTCSessionDescription(offerData['sdp'], offerData['type']);
    await _peerConnection!.setRemoteDescription(offer);

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _socketService.emitEvent(room, 'webrtc_answer', answer.toMap());
    
    _currentStatus = CallStatus.connected;
    _statusController.add(_currentStatus);
  }

  Future<void> _handleAnswer(Map<String, dynamic> answerData) async {
    RTCSessionDescription answer = RTCSessionDescription(answerData['sdp'], answerData['type']);
    await _peerConnection!.setRemoteDescription(answer);
    
    _currentStatus = CallStatus.connected;
    _statusController.add(_currentStatus);
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> candidateData) async {
    RTCIceCandidate candidate = RTCIceCandidate(
      candidateData['candidate'],
      candidateData['sdpMid'],
      candidateData['sdpMLineIndex'],
    );
    await _peerConnection!.addCandidate(candidate);
  }

  Future<void> _createPeerConnection([String? roomId]) async {
    final room = roomId ?? _appState.roomId ?? 'default';
    _peerConnection = await createPeerConnection(_iceServers, _config);

    _peerConnection!.onIceCandidate = (candidate) {
      _socketService.emitEvent(room, 'webrtc_ice_candidate', candidate.toMap());
    };

    _peerConnection!.onIceConnectionState = (state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        _currentStatus = CallStatus.connected;
        _statusController.add(_currentStatus);
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
                 state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        endCall(notifyPartner: true);
      }
    };

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer?.srcObject = event.streams[0];
      }
    };

    // Get local stream
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localRenderer?.srcObject = _localStream;
    
    // Use addTrack instead of addStream for Unified Plan support
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });
  }

  Future<void> endCall({bool notifyPartner = true}) async {
    if (notifyPartner) {
      _socketService.emitEvent(_appState.roomId ?? 'default', 'webrtc_end', {});
    }

    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    
    await _peerConnection?.close();
    _peerConnection = null;
    
    _currentStatus = CallStatus.ended;
    _statusController.add(_currentStatus);
    
    Future.delayed(const Duration(seconds: 1), () {
      _currentStatus = CallStatus.idle;
      _statusController.add(_currentStatus);
    });
  }
}
