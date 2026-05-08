
import 'socket_service.dart';
import '../../ui/notification_system.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final SocketService _socketService = SocketService();
  BuildContext? _context;

  void init(BuildContext context) {
    _context = context;
    // Listen to partner events to trigger "Notifications"
    _socketService.socketStream.listen(_handleIncomingEvent);
  }

  void _handleIncomingEvent(Map<String, dynamic> event) {
    if (_context == null) return;

    final type = event['type'];
    final data = event['data'];

    switch (type) {
      case 'memory_shared':
        SyncNotification.show(
          _context!,
          message: 'Partnerin yeni bir anı mühürledi! 💕',
          icon: Icons.favorite_rounded,
          type: NotificationType.info,
        );
        break;
      case 'mood_update':
        SyncNotification.show(
          _context!,
          message: 'Partnerin şu an ${data['mood']} hissediyor.',
          icon: Icons.bubble_chart_rounded,
          type: NotificationType.info,
        );
        break;
      case 'webrtc_offer':
        SyncNotification.show(
          _context!,
          message: 'Partnerin görüntülü arama başlatıyor...',
          icon: Icons.videocam_rounded,
          type: NotificationType.info,
        );
        break;
    }
  }

  void showLocal(String message, {required IconData icon, NotificationType type = NotificationType.info}) {
    if (_context != null) {
      SyncNotification.show(_context!, message: message, icon: icon, type: type);
    }
  }
}
