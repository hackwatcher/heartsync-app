import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../ui/sync_colors.dart';
import '../ui/motion_constants.dart';
import '../core/services/app_state.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  final AppState _appState = AppState();
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining();
    });
  }

  void _updateRemaining() {
    setState(() {
      _remaining = _appState.timeUntilReunion ?? Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _appState.reunionDate ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: SyncColors.coral,
            onPrimary: Colors.white,
            surface: SyncColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    final labelController = TextEditingController(text: _appState.reunionLabel);
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SyncColors.surface,
        title: Text('Buluşma adı', style: GoogleFonts.syne(color: Colors.white)),
        content: TextField(
          controller: labelController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Örn: Tokyo Buluşması ✈️',
            hintStyle: TextStyle(color: SyncColors.textSecondary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: SyncColors.glassBorder)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SyncColors.coral)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: SyncColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SyncColors.coral),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    await _appState.setReunionDate(picked, labelController.text.isEmpty ? 'Buluşma' : labelController.text);
    _updateRemaining();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hrs = _remaining.inHours % 24;
    final min = _remaining.inMinutes % 60;
    final sec = _remaining.inSeconds % 60;

    final hasDate = _appState.reunionDate != null;
    final dateStr = hasDate
        ? DateFormat('d MMMM yyyy', 'tr_TR').format(_appState.reunionDate!)
        : 'Henüz belirlenmedi';

    return Scaffold(
      body: Stack(
        children: [
          Container(color: SyncColors.background),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.edit_calendar_rounded, size: 14, color: SyncColors.coral),
                      label: const Text('Tarih değiştir', style: TextStyle(color: SyncColors.coral, fontSize: 12)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'Bir sonraki buluşma',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateStr,
                    style: GoogleFonts.dmSans(fontSize: 13, color: SyncColors.textSecondary),
                  ),

                  const SizedBox(height: 48),

                  if (!hasDate)
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: SyncColors.glassSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: SyncColors.coral.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.add_circle_outline_rounded, color: SyncColors.coral, size: 40),
                            const SizedBox(height: 12),
                            Text('Buluşma tarihini belirle', style: GoogleFonts.syne(color: SyncColors.coral, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Sayaç başlasın!', style: GoogleFonts.dmSans(fontSize: 12, color: SyncColors.textSecondary)),
                          ],
                        ),
                      ),
                    ).animate().fadeIn().scale()
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CountdownCard(value: days.toString().padLeft(2, '0'), label: 'GÜN'),
                        _CountdownCard(value: hrs.toString().padLeft(2, '0'), label: 'SAAT'),
                        _CountdownCard(value: min.toString().padLeft(2, '0'), label: 'DAK'),
                        _CountdownCard(value: sec.toString().padLeft(2, '0'), label: 'SN', trigger: sec),
                      ],
                    ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 32),

                  if (hasDate)
                    Text(
                      _appState.reunionLabel,
                      style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700),
                    ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 48),

                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: SyncColors.glassSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SyncColors.glassBorder),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined, color: SyncColors.textSecondary, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Varış noktanızın fotoğrafını ekleyin',
                            style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w300, color: SyncColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MilestoneChip(label: '${_daysTogether()} gün birlikte'),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _daysTogether() {
    // Could be personalized in a future update; placeholder for now
    return DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
  }
}

class _CountdownCard extends StatelessWidget {
  final String value;
  final String label;
  final int? trigger;

  const _CountdownCard({required this.value, required this.label, this.trigger});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: SyncColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SyncColors.glassBorder),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 40,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: SyncColors.coral,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w300, color: SyncColors.textSecondary, letterSpacing: 1),
          ),
        ],
      ),
    ).animate(key: trigger != null ? ValueKey(trigger) : null)
    .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 200.ms, curve: SyncMotion.springCurve)
    .then()
    .scale(begin: const Offset(1.05, 1.05), end: const Offset(1, 1));
  }
}

class _MilestoneChip extends StatelessWidget {
  final String label;
  const _MilestoneChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: SyncColors.coral.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
      child: Text(label, style: const TextStyle(fontSize: 10, color: SyncColors.coral, fontWeight: FontWeight.bold)),
    );
  }
}
