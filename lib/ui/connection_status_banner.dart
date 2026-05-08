import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sync_colors.dart';
import '../core/services/socket_service.dart' as ss;

class ConnectionStatusBanner extends StatefulWidget {
  const ConnectionStatusBanner({super.key});

  @override
  State<ConnectionStatusBanner> createState() => _ConnectionStatusBannerState();
}

class _ConnectionStatusBannerState extends State<ConnectionStatusBanner> {
  final ss.SocketService _socketService = ss.SocketService();
  ss.ConnectionState _state = ss.ConnectionState.disconnected;

  @override
  void initState() {
    super.initState();
    _state = _socketService.state;
    _socketService.connectionStream.listen((state) {
      if (mounted) setState(() => _state = state);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_state == ss.ConnectionState.connected) return const SizedBox.shrink();

    final (color, icon, message) = switch (_state) {
      ss.ConnectionState.connecting => (Colors.amber, Icons.sync_rounded, 'Bağlanıyor...'),
      ss.ConnectionState.error => (Colors.redAccent, Icons.wifi_off_rounded, _socketService.lastError ?? 'Bağlantı hatası'),
      ss.ConnectionState.disconnected => (SyncColors.textSecondary, Icons.wifi_off_rounded, 'Çevrimdışı — olaylar iletilmeyecek'),
      _ => (Colors.transparent, Icons.check, ''),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_state == ss.ConnectionState.error)
            TextButton(
              onPressed: () => _socketService.connect(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Tekrar dene', style: TextStyle(color: color, fontSize: 11)),
            ),
        ],
      ),
    ).animate().slideY(begin: -1, end: 0, duration: 300.ms);
  }
}
