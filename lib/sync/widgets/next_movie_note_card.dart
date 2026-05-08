import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/sync_colors.dart';

class NextMovieNoteCard extends StatefulWidget {
  const NextMovieNoteCard({super.key});

  @override
  State<NextMovieNoteCard> createState() => _NextMovieNoteCardState();
}

class _NextMovieNoteCardState extends State<NextMovieNoteCard> {
  final TextEditingController _controller = TextEditingController(text: 'Sıradaki filmimiz: Inception 🎬');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SyncColors.glassSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: SyncColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🍿 SIRADAKİ FİLM NOTUMUZ', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: SyncColors.coral, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Bir film notu bırak...',
                hintStyle: TextStyle(color: Colors.white24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
