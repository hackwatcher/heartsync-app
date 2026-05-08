import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../ui/sync_colors.dart';
import '../core/models/sync_models.dart';

class LoveJourneyScreen extends StatelessWidget {
  const LoveJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final relationship = HSRelationship.mock;
    final daysTogether = DateTime.now().difference(relationship.startDate).inDays;

    return Scaffold(
      backgroundColor: SyncColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Parallax Header
          SliverAppBar(
            expandedHeight: 300,
            stretch: true,
            pinned: true,
            backgroundColor: SyncColors.background,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Animated background glow
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.5,
                        colors: [SyncColors.coral.withValues(alpha: 0.4), Colors.transparent],
                      ),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 3.seconds),
                  
                  // Big Counter
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text('DAYS TOGETHER', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: SyncColors.coral, fontWeight: FontWeight.bold, letterSpacing: 4)),
                        Text('$daysTogether', style: GoogleFonts.syne(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: SyncColors.coral.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: SyncColors.coral.withValues(alpha: 0.3)),
                          ),
                          child: const Text('Every second counts', style: TextStyle(color: SyncColors.coral, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Journey Timeline
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 40),
                _buildSectionHeader('Our Milestones'),
                const SizedBox(height: 24),
                
                _JourneyItem(
                  date: 'Jan 1, 2024',
                  title: 'The First Spark',
                  description: 'The moment we realized this was something special.',
                  icon: Icons.auto_awesome_rounded,
                  isFirst: true,
                ),
                
                _JourneyItem(
                  date: 'Feb 14, 2024',
                  title: 'A Distance Defied',
                  description: 'First Valentine\'s Day across borders.',
                  icon: Icons.favorite_rounded,
                  hasImage: true,
                  imageUrl: 'https://images.unsplash.com/photo-1518199266791-5375a83190b7',
                ),
                
                _JourneyItem(
                  date: 'June 20, 2024',
                  title: 'Touching Down',
                  description: 'No more screens. Just you and me at the airport.',
                  icon: Icons.flight_takeoff_rounded,
                ),
                
                _JourneyItem(
                  date: 'Today',
                  title: 'Continuing the Story',
                  description: 'Building our future, one HeartSync at a time.',
                  icon: Icons.edit_calendar_rounded,
                  isLast: true,
                  isUpcoming: true,
                ),
              ]),
            ),
          ),
        ],
      ),
      // Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: SyncColors.coral,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('NEW MILESTONE', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 1.seconds, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: SyncColors.glassBorder)),
      ],
    );
  }
}

class _JourneyItem extends StatelessWidget {
  final String date;
  final String title;
  final String description;
  final IconData icon;
  final bool isFirst;
  final bool isLast;
  final bool isUpcoming;
  final bool hasImage;
  final String? imageUrl;

  const _JourneyItem({
    required this.date,
    required this.title,
    required this.description,
    required this.icon,
    this.isFirst = false,
    this.isLast = false,
    this.isUpcoming = false,
    this.hasImage = false,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline Path
          Column(
            children: [
              Container(width: 2, height: 20, color: isFirst ? Colors.transparent : SyncColors.glassBorder),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUpcoming ? Colors.transparent : SyncColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: isUpcoming ? SyncColors.glassBorder : SyncColors.coral, width: 2),
                  boxShadow: isUpcoming ? [] : [BoxShadow(color: SyncColors.coral.withValues(alpha: 0.2), blurRadius: 10)],
                ),
                child: Icon(icon, size: 20, color: isUpcoming ? SyncColors.textSecondary : SyncColors.coral),
              ),
              Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : SyncColors.glassBorder)),
            ],
          ),
          const SizedBox(width: 24),
          // Milestone Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isUpcoming ? Colors.transparent : SyncColors.glassSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: SyncColors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(date, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: SyncColors.textSecondary)),
                        if (!isUpcoming) const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.greenAccent),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(title, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: isUpcoming ? SyncColors.textSecondary : Colors.white)),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 13, color: SyncColors.textSecondary.withValues(alpha: 0.7), height: 1.4)),
                    
                    if (hasImage && imageUrl != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.05, end: 0);
  }
}
