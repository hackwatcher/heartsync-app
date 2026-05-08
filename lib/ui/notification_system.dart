import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sync_colors.dart';
import 'motion_constants.dart';

enum NotificationType { info, success, urgent }

class SyncNotification extends StatelessWidget {
  final String message;
  final IconData icon;
  final NotificationType type;

  const SyncNotification({
    super.key,
    required this.message,
    required this.icon,
    this.type = NotificationType.info,
  });

  static void show(BuildContext context, {
    required String message,
    required IconData icon,
    NotificationType type = NotificationType.info,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: SyncNotification(message: message, icon: icon, type: type)
            .animate()
            .slideY(begin: -1, end: 0, duration: SyncMotion.standard, curve: SyncMotion.springCurve)
            .fadeIn()
            .then(delay: 4.seconds)
            .fadeOut()
            .then()
            .callback(callback: (_) => entry.remove()),
        ),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: SyncColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: _getColor().withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: _getColor(), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: SyncColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor() {
    switch (type) {
      case NotificationType.success: return Colors.greenAccent;
      case NotificationType.urgent: return SyncColors.coral;
      case NotificationType.info: return SyncColors.violet;
    }
  }
}
