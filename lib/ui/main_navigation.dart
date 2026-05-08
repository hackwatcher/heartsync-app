import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../sync/home_screen.dart';
import '../sync/watch_room_screen.dart';
import '../stats/partner_profile_screen.dart';
import 'sync_colors.dart';
import 'global_notification_overlay.dart';
import 'video_call_overlay.dart';
import 'incoming_call_screen.dart';
import 'settings_screen.dart';

import '../core/services/call_service.dart';
import '../core/services/watch_service.dart';


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    CallService().initRenderers();
    WatchService().init();
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const WatchRoomScreen(),
    const PartnerProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _pages[_currentIndex],
          const GlobalNotificationOverlay(),
          const VideoCallOverlay(),
          const IncomingCallOverlay(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: -5),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TabItem(
                icon: Icons.home_rounded,
                label: 'Ana Sayfa',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _TabItem(
                icon: Icons.movie_creation_outlined,
                label: 'İzle',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _TabItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _TabItem(
                icon: Icons.settings_rounded,
                label: 'Ayarlar',
                isSelected: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? SyncColors.coral.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? SyncColors.coral : Colors.white60,
            ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: SyncColors.coral, fontSize: 12, fontWeight: FontWeight.bold),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}
