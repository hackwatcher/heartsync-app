import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sync_colors.dart';
import 'motion_constants.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String headline;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.headline,
    required this.body,
    this.ctaLabel,
    this.onCtaPressed,
  });

  // PRESETS
  static Widget noFilms() => const EmptyState(
    icon: Icons.chair_alt_rounded,
    headline: 'Your first film awaits.',
    body: 'Add films you want to watch together and Ayşe can vote on them.',
    ctaLabel: 'Browse films →',
  );

  static Widget partnerOffline() => const EmptyState(
    icon: Icons.nightlight_round,
    headline: 'Ayşe hasn\'t arrived yet.',
    body: 'It\'s 2:30 AM in Istanbul — she might be asleep. Leave her a film to wake up to?',
    ctaLabel: 'Send a film suggestion →',
  );

  static Widget connectionError() => const EmptyState(
    icon: Icons.airplanemode_inactive_rounded,
    headline: 'Lost the signal.',
    body: 'Check your connection — Ayşe is still out there.',
    ctaLabel: 'Try again',
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: SyncColors.coral.withValues(alpha: 0.5))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -10, duration: 3000.ms, curve: Curves.easeInOut),
          
          const SizedBox(height: 32),
          
          Text(
            headline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
          ).animate().fadeIn(duration: 600.ms),
          
          const SizedBox(height: 16),
          
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: SyncColors.textSecondary),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          
          if (ctaLabel != null) ...[
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: onCtaPressed ?? () {},
              child: Text(ctaLabel!),
            ).animate().fadeIn(delay: 600.ms).scale(curve: SyncMotion.springCurve),
          ],
        ],
      ),
    );
  }
}
