import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui/sync_colors.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/services/pairing_service.dart';
import 'auth_service.dart';

class TogetherApartScreen extends StatelessWidget {
  final VoidCallback onNext;
  const TogetherApartScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: SyncColors.background,
                    image: DecorationImage(
                      image: const NetworkImage('https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&q=80&w=390'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(SyncColors.background.withValues(alpha: 0.7), BlendMode.darken),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: SyncColors.background,
                    image: DecorationImage(
                      image: const NetworkImage('https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&q=80&w=390'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(SyncColors.background.withValues(alpha: 0.8), BlendMode.darken),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: SyncColors.coral, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: SyncColors.coral.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&q=80&w=200',
                  fit: BoxFit.cover,
                ),
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
          ),
          Positioned(
            bottom: 120,
            left: 40,
            right: 40,
            child: Column(
              children: [
                Text(
                  'One movie. Two cities. One heartbeat.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(delay: 500.ms).moveY(begin: 20, end: 0),
                const SizedBox(height: 48),
                
                // Google Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Trigger Google Login
                      final userCredential = await AuthService().signInWithGoogle();
                      if (userCredential != null) {
                        onNext();
                      } else {
                        // Show error or handle cancellation
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Giriş iptal edildi veya başarısız oldu.')),
                          );
                        }
                      }
                    },
                    icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white, size: 20),
                    label: const Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                  ),
                ).animate(delay: 1000.ms).fadeIn(),
                
                const SizedBox(height: 16),
                
                // Anonymous / Guest Login
                TextButton(
                  onPressed: onNext,
                  child: const Text('Continue as Guest', style: TextStyle(color: Colors.white54)),
                ).animate(delay: 1200.ms).fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PartnerConnectScreen extends StatefulWidget {
  const PartnerConnectScreen({super.key});

  @override
  State<PartnerConnectScreen> createState() => _PartnerConnectScreenState();
}

class _PartnerConnectScreenState extends State<PartnerConnectScreen> {
  final TextEditingController _codeController = TextEditingController();
  final PairingService _pairingService = PairingService();
  String _generatedCode = '';
  bool _isConnecting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generatedCode = _pairingService.generateNewCode();
  }

  Future<void> _handleConnect() async {
    if (_codeController.text.length < 6) return;
    setState(() { _isConnecting = true; _errorMessage = null; });
    final success = await _pairingService.connectWithCode(_codeController.text.toUpperCase());
    if (mounted) {
      setState(() {
        _isConnecting = false;
        if (!success) _errorMessage = 'Invalid pairing code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: SyncColors.background),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'Partnerinle Bağlan',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
                  ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _generatedCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kod kopyalandı!'),
                          backgroundColor: SyncColors.coral,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      decoration: BoxDecoration(
                        color: SyncColors.glassSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: SyncColors.coral.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _generatedCode,
                                style: GoogleFonts.jetBrainsMono(fontSize: 32, fontWeight: FontWeight.bold, color: SyncColors.coral, letterSpacing: 4),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.copy_rounded, color: SyncColors.coral, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('Bu kodu kopyalayıp partnerine gönder', style: TextStyle(fontSize: 10, color: SyncColors.textSecondary)),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: 10, duration: 3000.ms, curve: Curves.easeInOut),
                  ),
                  const SizedBox(height: 40),
                  Text('veya onun kodunu gir', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w300, color: SyncColors.textSecondary)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 8,
                    style: GoogleFonts.jetBrainsMono(color: SyncColors.textPrimary, letterSpacing: 6),
                    decoration: InputDecoration(
                      hintText: 'XXXXXXXX',
                      counterText: '',
                      hintStyle: TextStyle(color: SyncColors.textSecondary.withValues(alpha: 0.3)),
                      filled: true,
                      fillColor: SyncColors.glassSurface,
                      errorText: _errorMessage,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SyncColors.glassBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SyncColors.coral)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isConnecting ? null : _handleConnect,
                      child: _isConnecting 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Connect →'),
                    ),
                  ),
                  const SizedBox(height: 48),
                  StreamBuilder<PairingStatus>(
                    stream: _pairingService.statusStream,
                    builder: (context, snapshot) {
                      final status = snapshot.data ?? PairingStatus.waiting;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: status == PairingStatus.connected ? Colors.green : SyncColors.violet, shape: BoxShape.circle),
                          ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 1000.ms).fadeOut(),
                          const SizedBox(width: 12),
                          Text(status == PairingStatus.connected ? 'Partner Connected!' : 'Waiting for partner…', style: const TextStyle(fontSize: 12, color: SyncColors.textSecondary)),
                        ],
                      );
                    }
                  ),
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

class YourMomentScreen extends StatelessWidget {
  final VoidCallback onFinish;
  const YourMomentScreen({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Opacity(opacity: 0.1, child: CustomPaint(painter: _ParticlePainter()))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('What\'s your partner\'s name?', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn(),
                const SizedBox(height: 32),
                TextField(decoration: _inputDecoration('Partner Name'), style: Theme.of(context).textTheme.bodyLarge).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 24),
                TextField(decoration: _inputDecoration('Your Timezone'), style: Theme.of(context).textTheme.bodyLarge).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 64),
                ElevatedButton(onPressed: onFinish, child: const Text('Start watching together →')).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label, filled: true, fillColor: SyncColors.glassSurface,
      labelStyle: const TextStyle(color: SyncColors.textSecondary),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SyncColors.glassBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SyncColors.coral)),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = SyncColors.coral.withValues(alpha: 0.2);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 4, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.1), 2, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 3, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
