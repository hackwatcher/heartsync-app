import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sync_colors.dart';

class AICoWatchOverlay extends StatefulWidget {
  const AICoWatchOverlay({super.key});

  @override
  State<AICoWatchOverlay> createState() => _AICoWatchOverlayState();
}

class _AICoWatchOverlayState extends State<AICoWatchOverlay> {
  bool _isActive = false;
  String? _currentMessage;
  Timer? _messageTimer;

  final List<String> _aiPrompts = [
    "Did you feel the same way when you two first met? 💭",
    "This scene is beautifully shot! Notice the lighting shift? ✨",
    "I bet you two would make a great couple in this movie's universe! 🌌",
    "Awww, this is definitely a core memory moment. ❤️",
    "Fun fact: The actor improvised this entire line! 🎬",
    "Who do you think is going to win this argument? 🍿",
  ];

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _toggleAI() {
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        _scheduleNextMessage();
      } else {
        _messageTimer?.cancel();
        _currentMessage = null;
      }
    });
  }

  void _scheduleNextMessage() {
    // Show a message every 30 to 60 seconds randomly
    final delay = 30 + Random().nextInt(30);
    _messageTimer = Timer(Duration(seconds: delay), () {
      if (!mounted || !_isActive) return;
      setState(() {
        _currentMessage = _aiPrompts[Random().nextInt(_aiPrompts.length)];
      });
      
      // Hide message after 8 seconds
      Timer(const Duration(seconds: 8), () {
        if (!mounted || !_isActive) return;
        setState(() => _currentMessage = null);
        _scheduleNextMessage();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_currentMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: const BoxConstraints(maxWidth: 220),
              decoration: BoxDecoration(
                color: SyncColors.glassSurface,
                borderRadius: BorderRadius.circular(20).copyWith(bottomRight: const Radius.circular(4)),
                border: Border.all(color: SyncColors.coral.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(color: SyncColors.coral.withValues(alpha: 0.2), blurRadius: 10)],
              ),
              child: Text(
                _currentMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
              ),
            ).animate().slideX(begin: 1, end: 0, curve: Curves.easeOutBack).fadeIn(),
            
          GestureDetector(
            onTap: _toggleAI,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isActive ? SyncColors.coral : SyncColors.glassSurface,
                shape: BoxShape.circle,
                border: Border.all(color: _isActive ? Colors.white : SyncColors.glassBorder),
                boxShadow: _isActive ? [BoxShadow(color: SyncColors.coral.withValues(alpha: 0.5), blurRadius: 15, spreadRadius: 2)] : [],
              ),
              child: Icon(
                Icons.auto_awesome, 
                color: _isActive ? Colors.white : Colors.white70,
                size: 22,
              ),
            ),
          ).animate(target: _isActive ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
        ],
      ),
    );
  }
}
