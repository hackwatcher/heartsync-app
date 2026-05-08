import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui/sync_colors.dart';
import '../core/models/sync_models.dart';
import '../core/services/media_service.dart';

class VoiceNoteScreen extends StatefulWidget {
  const VoiceNoteScreen({super.key});

  @override
  State<VoiceNoteScreen> createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen> {
  final MediaService _mediaService = MediaService();
  bool _isRecording = false;
  final List<HSVoiceNote> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      _notes.addAll(_mediaService.notes);
    });
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    if (!_isRecording) {
      // Simulate saving a note
      final newNote = HSVoiceNote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: 'simulated_url',
        duration: const Duration(seconds: 45),
        createdAt: DateTime.now(),
        waveform: List.generate(30, (index) => math.Random().nextDouble()),
      );
      setState(() => _notes.insert(0, newNote));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: SyncColors.background),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Text('Voice Notes', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28)),
                    ],
                  ),
                ),
                
                Expanded(
                  child: _notes.isEmpty 
                    ? _EmptyNotes()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _notes.length,
                        itemBuilder: (context, index) => _VoiceNoteCard(note: _notes[index]),
                      ),
                ),
                
                // Recording Area
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: SyncColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isRecording)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(20, (i) => Container(
                            width: 3,
                            height: 10 + (math.Random().nextInt(30).toDouble()),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(color: SyncColors.coral, borderRadius: BorderRadius.circular(2)),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleY(begin: 0.5, end: 1.5, duration: 400.ms)),
                        ).animate().fadeIn(),
                      
                      const SizedBox(height: 32),
                      
                      GestureDetector(
                        onTap: _toggleRecording,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.white10 : SyncColors.coral,
                            shape: BoxShape.circle,
                            boxShadow: [
                              if (!_isRecording)
                                BoxShadow(color: SyncColors.coral.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                            color: _isRecording ? SyncColors.coral : Colors.white,
                            size: 40,
                          ),
                        ),
                      ).animate(target: _isRecording ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
                      
                      const SizedBox(height: 16),
                      Text(
                        _isRecording ? 'Listening…' : 'Tap to speak',
                        style: GoogleFonts.jetBrainsMono(fontSize: 12, color: SyncColors.textSecondary),
                      ),
                    ],
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

class _VoiceNoteCard extends StatelessWidget {
  final HSVoiceNote note;
  const _VoiceNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SyncColors.glassSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SyncColors.glassBorder),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: SyncColors.violet,
            child: Icon(Icons.play_arrow_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Voice Note', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                Text('${note.duration.inSeconds}s · Today', style: const TextStyle(fontSize: 11, color: SyncColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: SyncColors.textSecondary),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }
}

class _EmptyNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_none_rounded, size: 64, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text('No voice notes yet', style: TextStyle(color: SyncColors.textSecondary)),
        ],
      ),
    );
  }
}
