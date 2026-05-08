import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sync_colors.dart';
import 'main_navigation.dart';

import '../auth/onboarding_flow.dart';
import '../core/services/app_state.dart';
import '../core/services/auth_service.dart';
import '../core/services/pairing_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final authService = AuthService();
    final appState = AppState();
    
    await appState.loadFromStorage();
    await authService.checkAuth();
    
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (mounted) {
      // Route user: App entry is now fully open. No more room code locks!
      final hasAuth = authService.currentUser != null;

      if (hasAuth) {
        // Try auto connect if they have an old room, but don't block them if they don't
        await PairingService().tryAutoConnect();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingFlow()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: SyncColors.background),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [SyncColors.coral.withValues(alpha: 0.08), SyncColors.coral.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  Text('HeartSync', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48))
                      .animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),
                  Text('Mesafe sadece bir sayı.', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w300, color: SyncColors.coral))
                      .animate(delay: 80.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                  const Spacer(flex: 2),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: SyncColors.coral),
                  ).animate().fadeIn(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
