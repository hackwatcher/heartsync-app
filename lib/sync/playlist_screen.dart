import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui/sync_colors.dart';
import '../ui/motion_constants.dart';

class SharedPlaylistScreen extends StatelessWidget {
  const SharedPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: SyncColors.background),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Alex Status
                  const _AlexListeningStatus(),
                  
                  const SizedBox(height: 32),
                  Text(
                    'Playing in both worlds',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 26),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Now Playing Card
                  const _NowPlayingCard(),
                  
                  const SizedBox(height: 48),
                  
                  // Queue
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('UPCOMING', style: TextStyle(fontSize: 10, color: SyncColors.textSecondary, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 16),
                  
                  ...List.generate(3, (index) => _QueueTrackItem(index: index)),
                  
                  const SizedBox(height: 24),
                  
                  // Add Song Button
                  const _AddSongGhostButton(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlexListeningStatus extends StatelessWidget {
  const _AlexListeningStatus();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: SyncColors.glassSurface, borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: SyncColors.violet, shape: BoxShape.circle),
          ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5)).fadeOut(),
          const SizedBox(width: 8),
          const Text('Alex is listening now', style: TextStyle(fontSize: 10, color: SyncColors.violet, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SyncColors.glassSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: SyncColors.glassBorder),
      ),
      child: Column(
        children: [
          // Album Art Placeholder
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: SyncColors.romanticGradient,
              ),
              child: const Icon(Icons.music_note_rounded, size: 80, color: Colors.white24),
            ),
          ),
          const SizedBox(height: 32),
          
          Text('Before Sunrise', style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Lana Del Rey', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w300, color: SyncColors.textSecondary)),
          
          const SizedBox(height: 40),
          
          // Progress Bar
          LinearProgressIndicator(
            value: 0.65,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(SyncColors.coral),
            minHeight: 4,
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2:14', style: TextStyle(fontSize: 10, color: SyncColors.textSecondary)),
              Text('3:42', style: TextStyle(fontSize: 10, color: SyncColors.textSecondary)),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.skip_previous_rounded, color: SyncColors.coral, size: 32).animate().scale(curve: SyncMotion.springCurve),
              const SizedBox(width: 40),
              const Icon(Icons.pause_circle_filled_rounded, color: SyncColors.coral, size: 64).animate().scale(curve: SyncMotion.springCurve),
              const SizedBox(width: 40),
              const Icon(Icons.skip_next_rounded, color: SyncColors.coral, size: 32).animate().scale(curve: SyncMotion.springCurve),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueTrackItem extends StatelessWidget {
  final int index;
  const _QueueTrackItem({required this.index});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SyncColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SyncColors.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note, color: Colors.white24, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Moon River', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('Frank Sinatra', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w300, color: SyncColors.textSecondary)),
              ],
            ),
          ),
          // Added by avatar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: index == 0 ? SyncColors.coral.withValues(alpha: 0.2) : SyncColors.violet.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(50)),
            child: Text(index == 0 ? 'Y' : 'A', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: index == 0 ? SyncColors.coral : SyncColors.violet)),
          ),
        ],
      ),
    );
  }
}

class _AddSongGhostButton extends StatelessWidget {
  const _AddSongGhostButton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: SyncColors.coral.withValues(alpha: 0.3), width: 1, style: BorderStyle.solid), // Flutter doesn't have dashed natively easily without extra pkgs
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, color: SyncColors.coral, size: 20),
          const SizedBox(width: 12),
          Text('Add a song', style: GoogleFonts.dmSans(fontSize: 13, color: SyncColors.coral, fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }
}
