import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/services/socket_service.dart';
import 'sync_colors.dart';

class HSNotification {
  final String title;
  final String body;
  final IconData icon;

  HSNotification({required this.title, required this.body, required this.icon});
}

class GlobalNotificationOverlay extends StatefulWidget {
  const GlobalNotificationOverlay({super.key});

  @override
  State<GlobalNotificationOverlay> createState() => _GlobalNotificationOverlayState();
}

class _GlobalNotificationOverlayState extends State<GlobalNotificationOverlay> {
  final SocketService _socketService = SocketService();
  late StreamSubscription _subscription;
  HSNotification? _currentNotification;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _subscription = _socketService.socketStream.listen(_handleIncomingEvent);
  }

  void _handleIncomingEvent(Map<String, dynamic> event) {
    HSNotification? notification;
    final type = event['type'];
    final data = event['data'];

    switch (type) {
      case 'memory_shared':
        notification = HSNotification(
          title: 'Yeni Anı',
          body: 'Partnerin yeni bir anı paylaştı.',
          icon: Icons.favorite_rounded,
        );
        break;
      case 'mood_update':
        notification = HSNotification(
          title: 'Mood Değişti',
          body: 'Partnerin şu an ${data['mood']} hissediyor.',
          icon: Icons.bubble_chart_rounded,
        );
        break;
    }

    if (notification != null && mounted) {
      setState(() {
        _currentNotification = notification;
      });

      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _currentNotification = null);
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentNotification == null) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => setState(() => _currentNotification = null),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SyncColors.glassSurface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SyncColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(_currentNotification!.icon, color: SyncColors.coral, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentNotification!.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: SyncColors.textPrimary,
                        ),
                      ),
                      Text(
                        _currentNotification!.body,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          color: SyncColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: SyncColors.textSecondary),
                  onPressed: () => setState(() => _currentNotification = null),
                ),
              ],
            ),
          )
          .animate()
          .slideY(begin: -1, end: 0, duration: 600.ms, curve: Curves.easeOutBack)
          .fadeIn(),
        ),
      ),
    );
  }
}
