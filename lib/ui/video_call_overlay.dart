import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/services/call_service.dart';
import 'sync_colors.dart';

class VideoCallOverlay extends StatefulWidget {
  const VideoCallOverlay({super.key});

  @override
  State<VideoCallOverlay> createState() => _VideoCallOverlayState();
}

class _VideoCallOverlayState extends State<VideoCallOverlay> {
  final CallService _callService = CallService();
  Offset _localPos = const Offset(20, 100);
  Offset _remotePos = const Offset(20, 220);
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current status
    _isVisible = _callService.currentStatus == CallStatus.connected;
    
    _callService.statusStream.listen((status) {
      if (mounted) {
        setState(() => _isVisible = status == CallStatus.connected);
      }
    });
  }

  bool _showControls = false;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        // Remote Participant (Partner)
        Positioned(
          left: _remotePos.dx,
          top: _remotePos.dy,
          child: GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: Draggable(
              feedback: _buildVideoCircle('A', SyncColors.violet, isRemote: true, isDragging: true),
              childWhenDragging: const SizedBox.shrink(),
              onDragEnd: (details) => setState(() => _remotePos = details.offset),
              child: Column(
                children: [
                  if (_showControls) _buildControls(),
                  _buildVideoCircle('A', SyncColors.violet, isRemote: true),
                ],
              ),
            ),
          ),
        ),

        // Local Participant (You)
        Positioned(
          left: _localPos.dx,
          top: _localPos.dy,
          child: Draggable(
            feedback: _buildVideoCircle('Y', SyncColors.coral, isDragging: true),
            childWhenDragging: const SizedBox.shrink(),
            onDragEnd: (details) => setState(() => _localPos = details.offset),
            child: _buildVideoCircle('Y', SyncColors.coral),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: SyncColors.glassSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SyncColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _callService.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              size: 16,
              color: _callService.isMuted ? SyncColors.coral : Colors.white,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => setState(() => _callService.isMuted = !_callService.isMuted),
          ),
          IconButton(
            icon: Icon(
              _callService.isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
              size: 16,
              color: _callService.isCameraOff ? SyncColors.coral : Colors.white,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => setState(() => _callService.isCameraOff = !_callService.isCameraOff),
          ),
          SizedBox(
            width: 60,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                activeTrackColor: SyncColors.coral,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: _callService.remoteVolume,
                onChanged: (val) => setState(() => _callService.remoteVolume = val),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildVideoCircle(String label, Color color, {bool isRemote = false, bool isDragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: SyncColors.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.8), width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black54,
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Real WebRTC Video View
              Container(
                color: Colors.black26,
                child: (!isRemote && _callService.isCameraOff) 
                  ? const Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white24, size: 24))
                  : RTCVideoView(
                      isRemote ? _callService.remoteRenderer! : _callService.localRenderer!,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      mirror: !isRemote,
                    ),
              ),
              
              // Fallback label if video is slow/missing
              if (!isDragging)
                IgnorePointer(
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.1), 
                        fontWeight: FontWeight.bold, 
                        fontSize: 24
                      ),
                    ),
                  ),
                ),
              
              // Scanning/Live indicator
              Positioned(
                bottom: 10,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                ).animate(onPlay: (c) => c.repeat()).fadeOut(duration: 1000.ms),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
  }
}
