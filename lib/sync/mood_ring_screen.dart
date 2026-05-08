import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui/sync_colors.dart';

import '../core/services/app_state.dart';

class MoodRingScreen extends StatefulWidget {
  const MoodRingScreen({super.key});

  @override
  State<MoodRingScreen> createState() => _MoodRingScreenState();
}

class _MoodRingScreenState extends State<MoodRingScreen> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _moods = [
    {'label': 'Huzurlu', 'emoji': '🌿', 'color': Colors.tealAccent},
    {'label': 'Heyecanlı', 'emoji': '⚡', 'color': Colors.amberAccent},
    {'label': 'Özlem Dolu', 'emoji': '🌊', 'color': Colors.blueAccent},
    {'label': 'Eğlenceli', 'emoji': '🎡', 'color': Colors.orangeAccent},
    {'label': 'Yorgun', 'emoji': '☁️', 'color': Colors.blueGrey},
    {'label': 'Endişeli', 'emoji': '🧩', 'color': Colors.deepPurpleAccent},
    {'label': 'Minnettar', 'emoji': '🙏', 'color': Colors.greenAccent},
    {'label': 'Sevgi Dolu', 'emoji': '❤️', 'color': Colors.redAccent},
  ];

  @override
  Widget build(BuildContext context) {
    final activeMood = _moods[_selectedIndex];
    final moodColor = (activeMood['color'] as Color).withValues(alpha: 0.15);

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background Glow
          AnimatedContainer(
            duration: 800.ms,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [moodColor, SyncColors.background],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Şu an nasıl hissediyorsun?',
                    style: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                  
                  const Spacer(),
                  
                  // Circular Mood Ring
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glassy Ring Background
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10, width: 1),
                            boxShadow: [
                              BoxShadow(color: (activeMood['color'] as Color).withValues(alpha: 0.1), blurRadius: 40, spreadRadius: 5),
                            ],
                          ),
                        ),

                        // Interactive Arcs
                        ...List.generate(8, (index) {
                          final isSelected = _selectedIndex == index;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _selectedIndex = index);
                            },
                            child: CustomPaint(
                              size: const Size(320, 320),
                              painter: _MoodArcPainter(
                                index: index,
                                isSelected: isSelected,
                                color: _moods[index]['color'],
                              ),
                            ),
                          );
                        }),
                        
                        // Center Display with Glassmorphism
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                activeMood['emoji'],
                                style: const TextStyle(fontSize: 40),
                              ).animate(key: ValueKey('emoji_$_selectedIndex')).scale(curve: Curves.easeOutBack),
                              const SizedBox(height: 8),
                              Text(
                                activeMood['label'],
                                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          ),
                        ).animate().shimmer(duration: 2.seconds, color: Colors.white10),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Partner's Status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SyncColors.glassSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: SyncColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: SyncColors.violet.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: SyncColors.violet.withValues(alpha: 0.3)),
                          ),
                          child: const Center(child: Text('❤️', style: TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppState().partnerName} "Sevgi Dolu" hissediyor',
                                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const Text(
                                '4 saat önce · Evinden gönderildi',
                                style: TextStyle(fontSize: 11, color: SyncColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeMood['color'] as Color,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hissini ${AppState().partnerName} ile paylaştın! ✨'),
                            backgroundColor: SyncColors.surface,
                          ),
                        );
                      },
                      child: const Text('Bu hissi paylaş →', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ).animate().scale(delay: 600.ms),
                  
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

class _MoodArcPainter extends CustomPainter {
  final int index;
  final bool isSelected;
  final Color color;

  _MoodArcPainter({required this.index, required this.isSelected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    const sweepAngle = (2 * math.pi) / 8;
    final startAngle = index * sweepAngle - (math.pi / 2);

    final paint = Paint()
      ..color = isSelected ? color : color.withValues(alpha: 0.1)
      ..style = isSelected ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = isSelected ? 0 : 2
      ..strokeCap = StrokeCap.round;

    if (isSelected) {
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius + 5), startAngle + 0.05, sweepAngle - 0.1, true, shadowPaint);
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + 0.05,
      sweepAngle - 0.1,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
