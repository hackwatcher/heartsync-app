import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui/sync_colors.dart';
import '../ui/notification_system.dart';

import '../core/models/sync_models.dart';
import '../core/services/app_state.dart';
import '../core/services/media_service.dart';
import '../core/services/sync_service.dart';
import 'widgets/next_movie_note_card.dart';
import 'widgets/partner_context_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppState _appState = AppState();
  final SyncService _syncService = SyncService();
  final MediaService _mediaService = MediaService();
  late StreamSubscription _syncSubscription;
  late StreamSubscription _mediaSubscription;
  
  List<HSMemory> _memories = [];
  String _partnerMood = 'Peaceful';
  bool _showHeartbeatEffect = false;

  @override
  void initState() {
    super.initState();
    _syncSubscription = _syncService.eventStream.listen(_handleSyncEvent);
    _mediaSubscription = _mediaService.memoryStream.listen((memories) {
      if (mounted) setState(() => _memories = memories);
    });
    _mediaService.loadInitialMemories();

    // Broadcast our presence to the partner so their UI updates
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _syncService.sendEvent(SyncEventType.presence, data: true);
    });
  }

  void _handleSyncEvent(SyncEvent event) {
    

    if (mounted) {
      setState(() {
        switch (event.type) {
          case SyncEventType.heartbeat:
            _showHeartbeatEffect = true;
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _showHeartbeatEffect = false);
            });
            break;
          case SyncEventType.presence:
            break;
          case SyncEventType.moodUpdate:
            _partnerMood = event.data as String;
            break;
          default:
            break;
        }
      });
    }
  }

  @override
  void dispose() {
    _syncSubscription.cancel();
    _mediaSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: SyncColors.background),
          const _FilmGrainOverlay(),
          
          // Heartbeat Glow Effect
          if (_showHeartbeatEffect)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      SyncColors.coral.withValues(alpha: 0.15),
                      SyncColors.coral.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).fadeOut(delay: 1000.ms),
            ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _TopDashboardHeader(
                  partnerMood: _partnerMood,
                  showPulse: _showHeartbeatEffect,
                ),
                
                const SizedBox(height: 24),
                
                _ThinkingPulseButton(
                  onPulse: () {
                    _syncService.sendEvent(SyncEventType.heartbeat, data: true);
                    SyncNotification.show(context, message: 'Thinking of ${_appState.partnerName}...', icon: Icons.auto_awesome);
                  },
                ),
                
                const PartnerContextCard(),
                const NextMovieNoteCard(),
                
                const SizedBox(height: 12),
                

                const SizedBox(height: 32),
                
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _memories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _MemoryCard(memory: _memories[index], index: index),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopDashboardHeader extends StatelessWidget {
  final String partnerMood;
  final bool showPulse;

  const _TopDashboardHeader({
    required this.partnerMood,
    required this.showPulse,
  });

  String _getPartnerLocalTime(String partnerTimezone) {
    final now = DateTime.now().toUtc();
    
    // Mapping of common timezones to their UTC offsets
    final Map<String, int> tzOffsets = {
      'Europe/Istanbul': 3,
      'Europe/London': 1,
      'Europe/Paris': 2,
      'Europe/Berlin': 2,
      'America/New_York': -4,
      'America/Los_Angeles': -7,
      'America/Chicago': -5,
      'Asia/Tokyo': 9,
      'Asia/Seoul': 9,
      'Asia/Dubai': 4,
      'Asia/Singapore': 8,
      'Australia/Sydney': 10,
      'Pacific/Auckland': 12,
    };

    final offset = tzOffsets[partnerTimezone] ?? 0;
    final partnerTime = now.add(Duration(hours: offset));
    
    return '${partnerTime.hour.toString().padLeft(2, '0')}:${partnerTime.minute.toString().padLeft(2, '0')}';
  }

  bool _isDaytime(String partnerTimezone) {
    final now = DateTime.now().toUtc();
    final Map<String, int> tzOffsets = {
      'Europe/Istanbul': 3, 'Europe/London': 1, 'Europe/Paris': 2, 'Europe/Berlin': 2,
      'America/New_York': -4, 'America/Los_Angeles': -7, 'America/Chicago': -5,
      'Asia/Tokyo': 9, 'Asia/Seoul': 9, 'Asia/Dubai': 4, 'Asia/Singapore': 8,
      'Australia/Sydney': 10, 'Pacific/Auckland': 12,
    };
    final offset = tzOffsets[partnerTimezone] ?? 0;
    final partnerHour = now.add(Duration(hours: offset)).hour;
    return partnerHour >= 6 && partnerHour < 19;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final isDay = _isDaytime(appState.partnerTimezone);

    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  width: 176,
                  height: 96,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: _AvatarCircle(label: appState.myName.characters.first.toUpperCase(), color: SyncColors.coral),
                      ),
                      Positioned(
                        left: 80,
                        child: _AvatarCircle(
                          label: appState.partnerName.characters.first.toUpperCase(), 
                          color: SyncColors.violet,
                          isPulsing: showPulse,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${appState.myName} & ${appState.partnerName}',
                  style: GoogleFonts.syne(fontSize: 44, fontWeight: FontWeight.w700, color: SyncColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${appState.partnerName} $partnerMood hissediyor',
                      style: const TextStyle(fontSize: 12, color: SyncColors.coral, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 10, color: Colors.white24),
                    const SizedBox(width: 8),
                    Icon(isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round, size: 12, color: isDay ? Colors.amber : SyncColors.violet),
                    const SizedBox(width: 4),
                    Text(
                      _getPartnerLocalTime(appState.partnerTimezone),
                      style: const TextStyle(fontSize: 12, color: SyncColors.textSecondary, fontWeight: FontWeight.w400),
                    ),
                  ],
                ).animate(target: showPulse ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String label;
  final Color color;
  final bool isPulsing;

  const _AvatarCircle({
    required this.label, 
    required this.color,
    this.isPulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: isPulsing ? Colors.white : color, width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: isPulsing ? Colors.white : color, fontWeight: FontWeight.bold),
        ),
      ),
    ).animate(target: isPulsing ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2));
  }
}

// Presence status indicator removed.



class _ThinkingPulseButton extends StatelessWidget {
  final VoidCallback onPulse;
  const _ThinkingPulseButton({required this.onPulse});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onPulse,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SyncColors.glassSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SyncColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SyncColors.violet.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: SyncColors.violet),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SENİ DÜŞÜNÜYORUM', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: SyncColors.violet, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${AppState().partnerName}\'e bir parıltı gönder', style: const TextStyle(color: SyncColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: SyncColors.textSecondary),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _MemoryCard extends StatelessWidget {
  final HSMemory memory;
  final int index;
  const _MemoryCard({required this.memory, required this.index});

  @override
  Widget build(BuildContext context) {
    final hasLocalImage = memory.imageUrl != null && !memory.imageUrl!.startsWith('http');
    final hasNetworkImage = memory.imageUrl != null && memory.imageUrl!.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SyncColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SyncColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasLocalImage
                  ? Image.file(File(memory.imageUrl!), fit: BoxFit.cover)
                  : (hasNetworkImage
                      ? Image.network(memory.imageUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.image_outlined, color: Colors.white24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${memory.createdAt.day} ${_getMonthName(memory.createdAt.month)} ${memory.createdAt.year}',
                  style: const TextStyle(fontSize: 10, color: SyncColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  memory.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.9)),
                ),
                if (memory.isSealed) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: SyncColors.violet.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('MÜHÜRLÜ', style: TextStyle(fontSize: 8, color: SyncColors.violet, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
  }

  String _getMonthName(int month) {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return months[month - 1];
  }
}

class _FilmGrainOverlay extends StatelessWidget {
  const _FilmGrainOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.03,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://www.transparenttextures.com/patterns/stardust.png'),
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
      ),
    );
  }
}
