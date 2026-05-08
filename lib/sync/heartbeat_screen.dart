import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../ui/sync_colors.dart';
import '../core/services/sync_service.dart';
import '../ui/motion_constants.dart';
import '../ui/notification_system.dart';

class HeartbeatScreen extends StatefulWidget {
  const HeartbeatScreen({super.key});

  @override
  State<HeartbeatScreen> createState() => _HeartbeatScreenState();
}

class _HeartbeatScreenState extends State<HeartbeatScreen> {
  final SyncService _syncService = SyncService();
  bool _isHolding = false;
  bool _showFlash = false;

  void _onHoldStart() {
    setState(() => _isHolding = true);
  }

  void _onHoldEnd() {
    if (_isHolding) {
      _syncService.sendEvent(SyncEventType.heartbeat);
      
      setState(() {
        _isHolding = false;
        _showFlash = true;
      });
      
      // Simulation of Haptic Flash
      Future.delayed(200.ms, () => setState(() => _showFlash = false));
      
      // Confirmation Toast
      SyncNotification.show(
        context, 
        message: '💓 Alex felt your heartbeat', 
        icon: Icons.favorite,
        type: NotificationType.info,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: SyncColors.background),
          
          // Haptic Flash Overlay
          if (_showFlash)
            Container(color: SyncColors.violet.withValues(alpha: 0.08)),
            
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Pulsing Heart
                Center(
                  child: Icon(
                    Icons.favorite,
                    size: 160,
                    color: SyncColors.coral,
                  ).animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15),
                    duration: 600.ms,
                    curve: Curves.easeInOut,
                  ).then().scale(
                    begin: const Offset(1.15, 1.15),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                const Text(
                  'Hold to send your heartbeat',
                  style: TextStyle(fontSize: 14, color: SyncColors.textSecondary, fontWeight: FontWeight.w300),
                ),
                
                const Spacer(),
                
                // Press-and-hold button
                GestureDetector(
                  onTapDown: (_) => _onHoldStart(),
                  onTapUp: (_) => _onHoldEnd(),
                  onTapCancel: () => setState(() => _isHolding = false),
                  child: AnimatedContainer(
                    duration: 300.ms,
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHolding ? SyncColors.coral : SyncColors.glassSurface,
                      border: Border.all(color: SyncColors.coral, width: 2),
                      boxShadow: [
                        if (_isHolding)
                          BoxShadow(color: SyncColors.coral.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 5),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.touch_app_outlined,
                        color: _isHolding ? Colors.white : SyncColors.coral,
                      ),
                    ),
                  ).animate(target: _isHolding ? 1 : 0)
                  .scale(begin: const Offset(1, 1), end: const Offset(0.9, 0.9), curve: SyncMotion.springCurve),
                ),
                
                const SizedBox(height: 32),
                
                const Text(
                  '3 heartbeats today',
                  style: TextStyle(fontSize: 12, color: SyncColors.textSecondary, fontWeight: FontWeight.w300),
                ),
                
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
