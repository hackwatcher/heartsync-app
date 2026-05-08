import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../ui/sync_colors.dart';

class MemoryWallScreen extends StatelessWidget {
  const MemoryWallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Stats
          const SliverToBoxAdapter(child: _MemoryHeader()),
          
          // Timeline
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index % 5 == 0 && index != 0) {
                    return const _MilestoneCard();
                  }
                  return _TimelineItem(isLeft: index % 2 == 0, index: index);
                },
                childCount: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryHeader extends StatelessWidget {
  const _MemoryHeader();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Ayşe & Mehmet', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: SyncColors.glassSurface,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text('47 films · 94 hours · 284 reactions', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final bool isLeft;
  final int index;
  const _TimelineItem({required this.isLeft, required this.index});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isLeft) const Spacer(),
          
          // Card
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SyncColors.glassSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SyncColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network('https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&q=80&w=40', width: 40, height: 60, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Amélie', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Oct 24, 2026', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Text('😂', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 4),
                      Text('😭', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 4),
                      Text('❤️', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Center Line
          SizedBox(
            width: 40,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(width: 2, color: SyncColors.violet.withValues(alpha: 0.3)),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(color: SyncColors.coral, shape: BoxShape.circle),
                  ),
                ],
              ),
            ),
          ),
          
          if (isLeft) const Spacer(),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: isLeft ? -0.1 : 0.1, end: 0);
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: SyncColors.romanticGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Column(
          children: [
            Text('✨ 10 films together! ✨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('You two are officially cinephiles', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
