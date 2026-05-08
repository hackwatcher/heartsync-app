import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'persistence_service.dart';
import '../models/sync_models.dart';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final PersistenceService _persistenceService = PersistenceService();
  
  final List<HSMemory> _memories = [];
  final _memoryController = StreamController<List<HSMemory>>.broadcast();
  Stream<List<HSMemory>> get memoryStream => _memoryController.stream;

  /// Ses notu listesi — kayıtlar şimdilik ekran state'inde tutulur.
  List<HSVoiceNote> get notes => [];

  /// Simulates uploading a memory capsule and persists it locally
  Future<void> uploadMemory(HSMemory memory) async {
    // 1. Prepare for local persistence if media exists
    String? persistentImageUrl = memory.imageUrl;
    String? persistentVoiceUrl = memory.voiceUrl;

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String mediaDir = '${appDocDir.path}/media';
      await Directory(mediaDir).create(recursive: true);

      // Copy Image if local
      if (memory.imageUrl != null && !memory.imageUrl!.startsWith('http')) {
        final File originalFile = File(memory.imageUrl!);
        if (await originalFile.exists()) {
          final String extension = p.extension(memory.imageUrl!);
          final String newFileName = 'img_${memory.id}$extension';
          final File newFile = await originalFile.copy('$mediaDir/$newFileName');
          persistentImageUrl = newFile.path;
        }
      }

      // Copy Voice if local
      if (memory.voiceUrl != null && !memory.voiceUrl!.startsWith('http')) {
        final File originalFile = File(memory.voiceUrl!);
        if (await originalFile.exists()) {
          final String extension = p.extension(memory.voiceUrl!);
          final String newFileName = 'audio_${memory.id}$extension';
          final File newFile = await originalFile.copy('$mediaDir/$newFileName');
          persistentVoiceUrl = newFile.path;
        }
      }
    } catch (e) {
      print('Error persisting media: $e');
    }

    final persistentMemory = HSMemory(
      id: memory.id,
      title: memory.title,
      imageUrl: persistentImageUrl,
      voiceUrl: persistentVoiceUrl,
      createdAt: memory.createdAt,
      senderId: memory.senderId,
      isSealed: memory.isSealed,
    );

    // Simulate "uploading" delay
    await Future.delayed(const Duration(seconds: 2));
    
    _memories.insert(0, persistentMemory);
    await _saveMemories();
    _memoryController.add(List.from(_memories));
  }

  Future<void> _saveMemories() async {
    final list = _memories.map((m) => m.toJson()).toList();
    await _persistenceService.saveObject('hs_memories', list);
  }

  /// Load from storage and verify file existence
  Future<void> loadInitialMemories() async {
    final saved = await _persistenceService.getObject('hs_memories');
    if (saved != null && (saved as List).isNotEmpty) {
      _memories.clear();
      _memories.addAll(saved.map((m) => HSMemory.fromJson(m)).toList());
    } else {
      // Mock initial data
      _memories.addAll([
        HSMemory(
          id: 'm1',
          title: 'Yıldızların altında Amélie izlerken...',
          imageUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          senderId: 'user_1',
        ),
      ]);
      await _saveMemories();
    }
    _memoryController.add(List.from(_memories));
  }
}
