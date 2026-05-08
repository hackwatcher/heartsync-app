import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../ui/sync_colors.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: SyncColors.textSecondary),
                    hintText: 'Search for a film...',
                    hintStyle: const TextStyle(color: SyncColors.textSecondary),
                    filled: true,
                    fillColor: SyncColors.glassSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(color: SyncColors.glassBorder),
                    ),
                  ),
                ),
              ),
            ),
            
            // Mood Selector
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: const [
                    _MoodOrb(label: 'Cozy', gradient: [Colors.orange, Colors.amber]),
                    _MoodOrb(label: 'Thrilling', gradient: [Colors.blue, Colors.deepPurple]),
                    _MoodOrb(label: 'Laugh', gradient: [Colors.lightGreen, Colors.yellow]),
                    _MoodOrb(label: 'Deep', gradient: [SyncColors.coral, Colors.purple]),
                    _MoodOrb(label: 'Fun', gradient: [SyncColors.coral, Colors.orange]),
                  ],
                ),
              ),
            ),
            
            // Film Grid
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemBuilder: (context, index) {
                  return _FilmCard(index: index);
                },
                childCount: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodOrb extends StatelessWidget {
  final String label;
  final List<Color> gradient;

  const _MoodOrb({required this.label, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: gradient),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: SyncColors.textSecondary)),
        ],
      ),
    );
  }
}

class _FilmCard extends StatelessWidget {
  final int index;
  const _FilmCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMatchCheck(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: index == 2 ? Border.all(color: SyncColors.coral, width: 2) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&q=80&w=200&h=${200 + (index % 3) * 50}',
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                    ),
                  ),
                  child: const Text('Film Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: SyncColors.coral,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('84%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              if (index == 2)
                Positioned(
                  top: 8,
                  left: 8,
                  child: const Text('She loves this', style: TextStyle(fontSize: 8, color: SyncColors.coral, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).moveY(begin: 20, end: 0);
  }

  void _showMatchCheck(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: SyncColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: SyncColors.glassBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Match Check', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 30, backgroundColor: SyncColors.coral.withValues(alpha: 0.2), child: const Text('You')),
                const SizedBox(width: 32),
                CircleAvatar(radius: 30, backgroundColor: SyncColors.violet.withValues(alpha: 0.2), child: const Text('Ayşe')),
              ],
            ),
            const SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.close, size: 32), onPressed: () {}),
                const SizedBox(width: 48),
                IconButton(icon: const Icon(Icons.favorite, size: 40, color: SyncColors.coral), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
