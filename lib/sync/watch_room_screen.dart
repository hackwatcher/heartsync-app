import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../ui/sync_colors.dart';
import 'package:video_player/video_player.dart';
import '../core/services/watch_service.dart';
import '../core/services/socket_service.dart';
import '../core/services/call_service.dart';
import '../core/services/app_state.dart';

import '../core/services/pairing_service.dart';
import 'dart:ui';

import 'cinema_browser_screen.dart';

class WatchRoomScreen extends StatefulWidget {
  const WatchRoomScreen({super.key});

  @override
  State<WatchRoomScreen> createState() => _WatchRoomScreenState();
}

class _WatchRoomScreenState extends State<WatchRoomScreen> {
  final WatchService _watchService = WatchService();
  final SocketService _socketService = SocketService();
  final AppState _appState = AppState();
  final CallService _callService = CallService();
  
  late StreamSubscription _watchSubscription;
  late StreamSubscription _socketSubscription;
  bool _showControls = true;
  bool _isPlaying = false;
  bool _isCallActive = false;
  Offset _pipPosition = const Offset(16, 80);
  final List<Widget> _reactions = [];
  final List<Map<String, String>> _chatMessages = [];
  
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPartnerOnline = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = _watchService.isPlaying;
    
    // Initialize Video Player
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4'),
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          // Match current global state
          if (_isPlaying) _videoController!.play();
        }
      });
      
    // Listen for progress to update slider later
    _videoController!.addListener(() {
      if (mounted) setState(() {});
    });

    _watchSubscription = _watchService.watchEventStream.listen(_handleWatchEvent);
    _socketSubscription = _socketService.socketStream.listen((event) {
      if (mounted) {
        final sender = event['senderId'] as String? ?? '';
        final isMe = sender == 'user_${_socketService.socket?.id}';
        
        if (!isMe) {
          if (event['type'] == 'reaction') {
             _showReactionLocally(event['data']['emoji']);
          } else if (event['type'] == 'chat') {
             setState(() {
               _chatMessages.add({
                 'sender': _appState.partnerName,
                 'text': event['data']['text'] ?? ''
               });
             });
          }
        } else {
          // Socket messages from server/system or specifically for presence
          if (event['type'] == 'partner_online') {
            setState(() => _isPartnerOnline = true);
          } else if (event['type'] == 'partner_offline') {
            setState(() => _isPartnerOnline = false);
          }
        }
      }
    });
    
    // Listen to call status changes
    _callService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _isCallActive = status == CallStatus.connected;
        });
      }
    });
    _isCallActive = _callService.currentStatus == CallStatus.connected;
    
    // Request initial sync from partner if already in a room
    if (_appState.roomId != null) {
      _watchService.requestSync(_appState.roomId!);
    }
  }

  void _handleWatchEvent(WatchEvent event) {
    if (mounted) {
      setState(() {
        _isPlaying = _watchService.isPlaying;
      });
      
      if (_videoController != null && _isVideoInitialized) {
        if (event.type == WatchEventType.play) {
          final diff = (_videoController!.value.position - event.position).inMilliseconds.abs();
          if (diff > 500) {
            _videoController!.seekTo(event.position);
          }
          _videoController!.play();
        } else if (event.type == WatchEventType.pause) {
          _videoController!.pause();
          _videoController!.seekTo(event.position);
        } else if (event.type == WatchEventType.seek) {
          _videoController!.seekTo(event.position);
        } else if (event.type == WatchEventType.buffer) {
          // Partner requested sync, send our current position
          if (_videoController != null && _appState.roomId != null) {
            _watchService.sendSyncSnapshot(
              _appState.roomId!,
              _isPlaying,
              _videoController!.value.position,
            );
          }
        }
      }
    }
  }

  void _onPlayPause() {
    final newState = !_isPlaying;
    _watchService.sendCommand(
      newState ? WatchEventType.play : WatchEventType.pause,
      _videoController?.value.position ?? Duration.zero,
    );
  }
  
  void _onSeek(double value) {
    final newPos = Duration(milliseconds: value.toInt());
    _watchService.sendCommand(WatchEventType.seek, newPos);
  }

  void _addReaction(String emoji) {
    // 1. Send to partner
    _socketService.emitEvent(_appState.roomId ?? 'default', 'reaction', {'emoji': emoji});
    
    // 2. Show locally
    _showReactionLocally(emoji);
  }

  void _showReactionLocally(String emoji) {
    final key = UniqueKey();
    setState(() {
      _reactions.add(
        _FlyingEmoji(key: key, emoji: emoji, onComplete: () {
          if (mounted) {
            setState(() => _reactions.removeWhere((w) => w.key == key));
          }
        }),
      );
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _watchSubscription.cancel();
    _socketSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: _appState,
        builder: (context, child) {
          final hasRoom = _appState.roomId != null;
          return Stack(
            children: [
              RepaintBoundary(
                child: _AmbientBreathingGlow(isPlaying: _isPlaying),
              ),
              
              Column(
                children: [
                  // TOP BAR (Back in Column for natural spacing)
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('🎬 Sinema Modu', style: TextStyle(color: Colors.white60, fontSize: 13)),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CinemaBrowserScreen()));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: SyncColors.coral.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: SyncColors.coral),
                                  ),
                                  child: const Text('🌐 Platform Seç', style: TextStyle(color: SyncColors.coral, fontSize: 11)),
                                ),
                              ),
                              if (hasRoom) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: _appState.roomId!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Oda kodu kopyalandı!')),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.copy_rounded, color: Colors.white60, size: 10),
                                        const SizedBox(width: 4),
                                        Text(
                                          _appState.roomId!,
                                          style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          // Video Call Toggle Button
                          GestureDetector(
                            onTap: () {
                              if (_isCallActive) {
                                _callService.endCall(notifyPartner: true);
                              } else {
                                _callService.startCall();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isCallActive 
                                  ? Colors.green.withValues(alpha: 0.15) 
                                  : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isCallActive ? Colors.green.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isCallActive ? Icons.videocam_rounded : Icons.videocam_outlined,
                                    size: 16,
                                    color: _isCallActive ? Colors.greenAccent : Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isCallActive ? 'Görüşmede' : 'Ara',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _isCallActive ? Colors.greenAccent : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // VIDEO PLAYER AREA
                  Expanded(
                    flex: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _showControls = !_showControls),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        decoration: BoxDecoration(
                          color: SyncColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: _isVideoInitialized 
                                ? AspectRatio(
                                    aspectRatio: _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CircularProgressIndicator(color: SyncColors.coral),
                                      const SizedBox(height: 16),
                                      const Text('Film Yükleniyor...', style: TextStyle(color: Colors.white54)),
                                    ],
                                  ),
                            ),
                            Positioned.fill(child: Container(color: Colors.transparent)),
                            ..._reactions,
                            Positioned(top: 16, right: 16, child: _SyncIndicator(isOnline: _isPartnerOnline)),
                            const Positioned(top: 16, left: 16, child: _PartnerAvatarReaction()),
                            if (_showControls)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: _VideoControlBar(
                                  isPlaying: _isPlaying,
                                  onToggle: _onPlayPause,
                                  controller: _videoController,
                                  onSeek: _onSeek,
                                ),
                              ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // REACTION PANEL
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _QuickReactionsRow(
                            onEmojiTap: _addReaction,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              reverse: true,
                              itemCount: _chatMessages.length,
                              itemBuilder: (context, index) {
                                final msg = _chatMessages[_chatMessages.length - 1 - index];
                                final isMe = msg['sender'] == 'Sen';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${msg['sender']}: ', 
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          color: isMe ? Colors.white : SyncColors.coral
                                        )
                                      ),
                                      Expanded(
                                        child: Text(
                                          msg['text']!, 
                                          style: const TextStyle(color: Colors.white70)
                                        )
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ChatBubbleInput(
                            onSend: (text) {
                              _socketService.emitEvent(_appState.roomId ?? 'default', 'chat', {'text': text});
                              setState(() {
                                _chatMessages.add({'sender': 'Sen', 'text': text});
                              });
                            },
                          ),
                          const SizedBox(height: 90), // Navigation bar height clearance
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // PiP Camera during call (draggable)
              if (_isCallActive && _callService.remoteRenderer != null)
                Positioned(
                  left: _pipPosition.dx,
                  top: _pipPosition.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _pipPosition += details.delta;
                      });
                    },
                    child: _PipCallView(
                      localRenderer: _callService.localRenderer!,
                      remoteRenderer: _callService.remoteRenderer!,
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
                ),
              if (!hasRoom) const _RoomConnectOverlay(),
            ],
          );
        },
      ),
    );
  }
}

class _FlyingEmoji extends StatelessWidget {
  final String emoji;
  final VoidCallback onComplete;
  const _FlyingEmoji({super.key, required this.emoji, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final randomX = (50 + (math.Random().nextDouble() * 200));
    return Positioned(
      bottom: 20,
      left: randomX,
      child: Text(emoji, style: const TextStyle(fontSize: 40))
          .animate(onComplete: (_) => onComplete())
          .moveY(begin: 0, end: -300, duration: 2.seconds, curve: Curves.easeOutCubic)
          .fadeOut(delay: 1.seconds),
    );
  }
}

class _VideoControlBar extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onToggle;
  final VideoPlayerController? controller;
  final Function(double) onSeek;
  
  const _VideoControlBar({
    required this.isPlaying, 
    required this.onToggle,
    this.controller,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final position = controller?.value.position ?? Duration.zero;
    final duration = controller?.value.duration ?? Duration.zero;
    
    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
      return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(formatDuration(position), style: const TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    activeTrackColor: SyncColors.coral,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: SyncColors.coral,
                  ),
                  child: Slider(
                    value: position.inMilliseconds.toDouble(),
                    min: 0.0,
                    max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                    onChanged: onSeek,
                  ),
                ),
              ),
              Text(formatDuration(duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white, size: 28),
                onPressed: () => onSeek((position.inMilliseconds - 10000).toDouble()),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SyncColors.coral,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: SyncColors.coral.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white, size: 28),
                onPressed: () => onSeek((position.inMilliseconds + 10000).toDouble()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickReactionsRow extends StatelessWidget {
  final Function(String) onEmojiTap;
  const _QuickReactionsRow({required this.onEmojiTap});

  @override
  Widget build(BuildContext context) {
    final emojis = ['❤️', '😂', '😲', '😱', '🤯', '😢'];
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onEmojiTap(emojis[index]),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(emojis[index], style: const TextStyle(fontSize: 28)),
                  ),
                ).animate().fadeIn(delay: (index * 50).ms).scale();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientBreathingGlow extends StatelessWidget {
  final bool isPlaying;
  const _AmbientBreathingGlow({required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: SyncColors.coral.withValues(alpha: isPlaying ? 0.08 : 0.02),
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
    .custom(
      duration: isPlaying ? 2500.ms : 6000.ms,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
    );
  }
}

class _SyncIndicator extends StatelessWidget {
  final bool isOnline;
  const _SyncIndicator({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.white10, 
          width: 0.5
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? Colors.greenAccent : Colors.white24, 
              shape: BoxShape.circle,
              boxShadow: isOnline ? [
                BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)
              ] : null,
            ),
          ).animate(onPlay: (c) => isOnline ? c.repeat() : c.stop())
           .fade(duration: 800.ms),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'SENKRONİZE' : 'BEKLENİYOR...', 
            style: TextStyle(
              fontSize: 10, 
              color: isOnline ? Colors.white : Colors.white38, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 0.5
            )
          ),
        ],
      ),
    );
  }
}



class _ChatBubbleInput extends StatefulWidget {
  final Function(String) onSend;
  const _ChatBubbleInput({required this.onSend});

  @override
  State<_ChatBubbleInput> createState() => _ChatBubbleInputState();
}

class _ChatBubbleInputState extends State<_ChatBubbleInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      textInputAction: TextInputAction.send,
      onSubmitted: (text) {
        if (text.trim().isNotEmpty) {
          widget.onSend(text.trim());
          _controller.clear();
        }
      },
      decoration: InputDecoration(
        hintText: 'Partnerinle fısıldaş...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
        filled: true,
        fillColor: SyncColors.glassSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send_rounded, color: SyncColors.coral, size: 20),
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onSend(_controller.text.trim());
              _controller.clear();
            }
          },
        ),
      ),
    );
  }
}

class _PartnerAvatarReaction extends StatelessWidget {
  const _PartnerAvatarReaction();
  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final photoUrl = appState.partnerPhotoUrl;
    final initials = appState.partnerName.isNotEmpty ? appState.partnerName[0] : 'P';

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SyncColors.coral.withValues(alpha: 0.2),
        border: Border.all(color: SyncColors.coral.withValues(alpha: 0.5), width: 1.5),
        image: photoUrl != null 
          ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
          : null,
      ),
      child: photoUrl == null 
        ? Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))
        : null,
    ).animate(onPlay: (c) => c.repeat(reverse: true))
    .moveY(begin: 0, end: -4, duration: 2000.ms);
  }
}

// Picture-in-Picture (PiP) camera widget for watching together while on call
class _PipCallView extends StatefulWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  const _PipCallView({
    required this.localRenderer,
    required this.remoteRenderer,
  });

  @override
  State<_PipCallView> createState() => _PipCallViewState();
}

class _PipCallViewState extends State<_PipCallView> {
  bool _showControls = false;
  final CallService _callService = CallService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Container(
        width: 140,
        height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SyncColors.coral.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Remote (partner) video — large
            Positioned.fill(
              child: RTCVideoView(
                widget.remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
            
            // Local (self) video — small bottom corner
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                width: 45,
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: _callService.isCameraOff
                    ? const Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white24, size: 20))
                    : RTCVideoView(
                        widget.localRenderer,
                        mirror: true,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                ),
              ),
            ),
            
            // Hover Controls (Mute / Camera)
            if (_showControls)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(_callService.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded),
                          color: _callService.isMuted ? SyncColors.coral : Colors.white,
                          iconSize: 24,
                          onPressed: () => setState(() => _callService.isMuted = !_callService.isMuted),
                        ),
                        IconButton(
                          icon: Icon(_callService.isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded),
                          color: _callService.isCameraOff ? SyncColors.coral : Colors.white,
                          iconSize: 24,
                          onPressed: () => setState(() => _callService.isCameraOff = !_callService.isCameraOff),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms),
            
            // Header label
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_rounded, color: Colors.green, size: 10),
                      SizedBox(width: 4),
                      Text('Canlı', style: TextStyle(color: Colors.white, fontSize: 9)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _RoomConnectOverlay extends StatefulWidget {
  const _RoomConnectOverlay();

  @override
  State<_RoomConnectOverlay> createState() => _RoomConnectOverlayState();
}

class _RoomConnectOverlayState extends State<_RoomConnectOverlay> {
  final TextEditingController _codeController = TextEditingController();
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_rounded, size: 48, color: SyncColors.coral),
                const SizedBox(height: 16),
                const Text(
                  'Bağlantı Gerekli',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Birlikte bir şeyler izlemek için bir oda oluşturun veya var olan bir odaya katılın.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 48),
                
                // Create Room Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: SyncColors.coral,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Oda Oluştur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      PairingService().generateNewCode();
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('veya', style: TextStyle(color: Colors.white54)),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Join Room Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextField(
                    controller: _codeController,
                    style: const TextStyle(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'ODA KODU',
                      hintStyle: TextStyle(letterSpacing: 2, color: Colors.white30),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Join Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: SyncColors.surface,
                      foregroundColor: SyncColors.coral,
                    ),
                    onPressed: _isJoining ? null : () async {
                      if (_codeController.text.trim().length >= 4) {
                        setState(() => _isJoining = true);
                        await PairingService().connectWithCode(_codeController.text.trim().toUpperCase());
                        if (mounted) setState(() => _isJoining = false);
                      }
                    },
                    child: _isJoining
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: SyncColors.coral))
                        : const Text('Odaya Katıl', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

