import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../ui/sync_colors.dart';
import '../core/services/app_state.dart';
import '../core/services/media_service.dart';
import '../core/models/sync_models.dart';

class PartnerProfileScreen extends StatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  State<PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends State<PartnerProfileScreen> {
  final MediaService _mediaService = MediaService();
  List<HSMemory> _memories = [];

  @override
  void initState() {
    super.initState();
    _mediaService.memoryStream.listen((memories) {
      if (mounted) setState(() => _memories = memories);
    });
    _mediaService.loadInitialMemories();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with blurred collage
            _ProfileHeader(
              name: appState.myName, 
              timezone: appState.myTimezone,
              photoUrl: appState.myPhotoUrl,
              age: appState.myAge,
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Anı Duvarı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _MemoryWall(memories: _memories),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String timezone;
  final String? photoUrl;
  final int? age;
  
  const _ProfileHeader({
    required this.name, 
    required this.timezone,
    this.photoUrl,
    this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Blurred Collage Background
        Container(
          height: 280,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&q=80&w=400'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [SyncColors.background.withValues(alpha: 0.2), SyncColors.background],
              ),
            ),
          ),
        ),
        
        Positioned(
          bottom: 24,
          child: Column(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: SyncColors.coral,
                child: CircleAvatar(
                  radius: 49,
                  backgroundColor: SyncColors.surface,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null 
                    ? Text(
                        name.characters.first.toUpperCase(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: SyncColors.coral),
                      )
                    : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                age != null ? "$name, $age" : name, 
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32)
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: SyncColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(timezone, style: const TextStyle(fontSize: 12, color: SyncColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MemoryWall extends StatelessWidget {
  final List<HSMemory> memories;
  const _MemoryWall({required this.memories});

  @override
  Widget build(BuildContext context) {
    final imageMemories = memories.where((m) => m.imageUrl != null).toList();
    
    if (imageMemories.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: SyncColors.glassSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SyncColors.glassBorder),
        ),
        child: const Center(
          child: Text('Henüz fotoğraf eklenmemiş', style: TextStyle(color: SyncColors.textSecondary, fontSize: 12)),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageMemories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final m = imageMemories[index];
          final isLocal = !m.imageUrl!.startsWith('http');
          
          return Container(
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SyncColors.glassBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isLocal 
                  ? Image.file(File(m.imageUrl!), fit: BoxFit.cover)
                  : Image.network(m.imageUrl!, fit: BoxFit.cover),
            ),
          ).animate().fadeIn(delay: (index * 100).ms).scale(begin: const Offset(0.9, 0.9));
        },
      ),
    );
  }
}


