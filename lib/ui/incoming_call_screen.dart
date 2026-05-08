import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/services/call_service.dart';
import '../core/services/app_state.dart';
import 'sync_colors.dart';

class IncomingCallOverlay extends StatefulWidget {
  const IncomingCallOverlay({super.key});

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay> {
  final CallService _callService = CallService();
  final AppState _appState = AppState();
  
  bool _isVisible = false;
  StreamSubscription? _incomingCallSub;

  @override
  void initState() {
    super.initState();
    _incomingCallSub = _callService.incomingCallStream.listen((incoming) {
      if (mounted) setState(() => _isVisible = incoming);
    });
  }

  @override
  void dispose() {
    _incomingCallSub?.cancel();
    super.dispose();
  }

  void _accept() {
    if (_callService.pendingOffer != null) {
      _callService.acceptCall(_callService.pendingOffer!);
    }
    setState(() => _isVisible = false);
  }

  void _reject() {
    _callService.endCall(notifyPartner: true);
    setState(() => _isVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Deep Glass Background
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(),
              ),
            ),

            // Animated background blobs
            _AnimatedBlob(color: SyncColors.violet, top: -100, left: -100),
            _AnimatedBlob(color: SyncColors.coral, bottom: -100, right: -100),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing Avatar
                _PulsingAvatar(name: _appState.partnerName),
                
                const SizedBox(height: 32),
                
                Text(
                  _appState.partnerName,
                  style: GoogleFonts.syne(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 8),
                
                Text(
                  'Görüntülü Arama...',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ).animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2000.ms, color: SyncColors.coral),
                
                const SizedBox(height: 72),
                
                // Accept / Reject Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reject
                    _CallActionButton(
                      icon: Icons.call_end_rounded,
                      color: Colors.red,
                      label: 'Reddet',
                      onTap: _reject,
                    ),
                    const SizedBox(width: 80),
                    // Accept
                    _CallActionButton(
                      icon: Icons.videocam_rounded,
                      color: Colors.green,
                      label: 'Kabul Et',
                      onTap: _accept,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _PulsingAvatar extends StatefulWidget {
  final String name;
  const _PulsingAvatar({required this.name});

  @override
  State<_PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<_PulsingAvatar> {
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    _startVibrationLoop();
  }

  @override
  void dispose() {
    _vibrationTimer?.cancel();
    super.dispose();
  }

  void _startVibrationLoop() {
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?';
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulse ring 1
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: SyncColors.violet.withValues(alpha: 0.2), width: 2),
          ),
        ).animate(onPlay: (c) => c.repeat())
          .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 2000.ms)
          .fadeOut(begin: 1, curve: Curves.easeOut),
        
        // Profile Avatar
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SyncColors.surface,
            border: Border.all(color: SyncColors.coral, width: 3),
            boxShadow: [
              BoxShadow(
                color: SyncColors.coral.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: GoogleFonts.syne(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 3000.ms, color: Colors.white24),
      ],
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final Color color;
  final double? top, bottom, left, right;

  const _AnimatedBlob({required this.color, this.top, this.bottom, this.left, this.right});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.3), Colors.transparent],
          ),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 3000.ms)
        .fadeIn(duration: 1000.ms),
    );
  }
}
