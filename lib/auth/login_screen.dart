import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../ui/sync_colors.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SyncColors.background,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [SyncColors.violet.withValues(alpha: 0.2), SyncColors.background],
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Brand Logo
                _HeartSyncLogo(),
                
                const SizedBox(height: 24),
                const Text('HeartSync', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text('Sync your hearts, share the moment.', style: TextStyle(color: SyncColors.textSecondary, fontSize: 14)),
                
                const SizedBox(height: 60),

                // Apple Login Button
                _SocialButton(
                  icon: Icons.apple,
                  label: 'Continue with Apple',
                  color: Colors.black,
                  onPressed: () => _handleLogin(context),
                ),
                
                const SizedBox(height: 16),

                // Google Login Button
                _SocialButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  color: Colors.white,
                  textColor: Colors.black,
                  isGoogle: true,
                  onPressed: () => _handleLogin(context),
                ),
                
                const SizedBox(height: 40),
                
                // Premium Teaser
                TextButton(
                  onPressed: () {},
                  child: Text('Unlock Premium Features', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: SyncColors.coral, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                ),
                
                const SizedBox(height: 24),
                Text('By continuing, you agree to our Terms & Privacy Policy', 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SyncColors.textSecondary.withValues(alpha: 0.5), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    // Show a premium loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: SyncColors.surface, borderRadius: BorderRadius.circular(20)),
          child: const CircularProgressIndicator(color: SyncColors.coral),
        ),
      ),
    );

    // Simulate Auth Delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading
      onLoginSuccess();
    });
  }
}

class _HeartSyncLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: SyncColors.coral.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .shimmer(duration: 3.seconds, color: Colors.white24)
     .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 2.seconds);
  }
}

class _SocialButton extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;
  final bool isGoogle;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    this.textColor = Colors.white,
    required this.onPressed,
    this.isGoogle = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isGoogle ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          ),
          elevation: color == Colors.white ? 2 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
               ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.blue, Colors.red, Colors.yellow, Colors.green],
                ).createShader(bounds),
                child: Icon(icon, size: 24, color: Colors.white),
              )
            else
              Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0);
  }
}
