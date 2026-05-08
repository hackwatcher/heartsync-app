import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui/sync_colors.dart';
import '../ui/motion_constants.dart';

class TimezoneBridgeScreen extends StatefulWidget {
  const TimezoneBridgeScreen({super.key});

  @override
  State<TimezoneBridgeScreen> createState() => _TimezoneBridgeScreenState();
}

class _TimezoneBridgeScreenState extends State<TimezoneBridgeScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: SyncColors.background),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Your overlap window',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 26),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Dual Clocks
                  Row(
                    children: [
                      Expanded(child: _ClockCard(city: 'LONDON', time: _now, color: SyncColors.coral)),
                      const SizedBox(width: 16),
                      Expanded(child: _ClockCard(city: 'ISTANBUL', time: _now.add(const Duration(hours: 3)), color: SyncColors.violet)),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Overlap Visualizer
                  const _OverlapTimeline(),
                  
                  const Spacer(),
                  
                  // Best Time to Call
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: SyncColors.glassSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: SyncColors.glassBorder),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, color: SyncColors.coral, size: 32),
                        const SizedBox(height: 16),
                        const Text('Best time to call', style: TextStyle(fontSize: 12, color: SyncColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text(
                          '7:00 – 9:00 PM your time',
                          style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: SyncColors.textPrimary),
                        ),
                      ],
                    ),
                  ).animate().scale(curve: SyncMotion.springCurve).fadeIn(),
                  
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

class _ClockCard extends StatelessWidget {
  final String city;
  final DateTime time;
  final Color color;

  const _ClockCard({required this.city, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SyncColors.glassSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SyncColors.glassBorder),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _AnalogClockPainter(time: time, color: color),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            city,
            style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  final DateTime time;
  final Color color;

  _AnalogClockPainter({required this.time, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Face
    canvas.drawCircle(center, radius, Paint()..color = Colors.white10..style = PaintingStyle.stroke..strokeWidth = 2);
    
    // Hour hand
    final hourAngle = (time.hour % 12 + time.minute / 60) * 30 * math.pi / 180;
    canvas.drawLine(center, center + Offset(math.sin(hourAngle) * radius * 0.5, -math.cos(hourAngle) * radius * 0.5), Paint()..color = color..strokeWidth = 4..strokeCap = StrokeCap.round);
    
    // Minute hand
    final minuteAngle = (time.minute + time.second / 60) * 6 * math.pi / 180;
    canvas.drawLine(center, center + Offset(math.sin(minuteAngle) * radius * 0.7, -math.cos(minuteAngle) * radius * 0.7), Paint()..color = color..strokeWidth = 3..strokeCap = StrokeCap.round);
    
    // Second hand
    final secondAngle = time.second * 6 * math.pi / 180;
    canvas.drawLine(center, center + Offset(math.sin(secondAngle) * radius * 0.8, -math.cos(secondAngle) * radius * 0.8), Paint()..color = color.withValues(alpha: 0.5)..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _OverlapTimeline extends StatelessWidget {
  const _OverlapTimeline();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6)),
          child: Stack(
            children: [
              // User awake
              FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: 0.6, child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: SyncColors.coral.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6)))),
              // Partner awake
              FractionallySizedBox(alignment: Alignment.centerRight, widthFactor: 0.5, child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: SyncColors.violet.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6)))),
              // Overlap
              Align(alignment: Alignment.center, child: Container(width: 80, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6)))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('2.5h overlap tonight', style: TextStyle(fontSize: 10, color: SyncColors.textSecondary, letterSpacing: 0.5)),
      ],
    );
  }
}
