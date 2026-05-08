import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'sync_colors.dart';
import 'splash_screen.dart';
import '../core/services/app_state.dart';
import '../core/services/persistence_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              Container(color: SyncColors.background),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),


                      // Avatar Section
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(color: SyncColors.coral, shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  _appState.myName.isNotEmpty ? _appState.myName[0].toUpperCase() : 'S',
                                  style: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${_appState.myName} & ${_appState.partnerName}',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 22),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      _SectionTitle('Profil'),
                      const SizedBox(height: 12),

                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Adın',
                        subtitle: _appState.myName,
                        onTap: () => _editName(context, isMe: true),
                      ),
                      _SettingsTile(
                        icon: Icons.favorite_border_rounded,
                        title: 'Partner adı',
                        subtitle: _appState.partnerName,
                        onTap: () => _editName(context, isMe: false),
                      ),

                      const SizedBox(height: 32),
                      _SectionTitle('Saat Dilimleri'),
                      const SizedBox(height: 12),

                      _SettingsTile(
                        icon: Icons.schedule_rounded,
                        title: 'Senin saat dilimin',
                        subtitle: _appState.myTimezone,
                        onTap: () => _editTimezone(context, isMe: true),
                      ),
                      _SettingsTile(
                        icon: Icons.schedule_outlined,
                        title: '${_appState.partnerName}\'in saat dilimi',
                        subtitle: _appState.partnerTimezone,
                        onTap: () => _editTimezone(context, isMe: false),
                      ),

                      const SizedBox(height: 32),
                      _SectionTitle('Uygulama'),
                      const SizedBox(height: 12),

                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Bildirimler',
                        subtitle: _appState.notificationsEnabled ? 'Açık' : 'Kapalı',
                        onTap: () async {
                          await _appState.setNotificationsEnabled(!_appState.notificationsEnabled);
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Tema',
                        subtitle: _appState.darkModeEnabled ? 'Karanlık Mod (Önerilen)' : 'Açık Mod (Beta)',
                        onTap: () async {
                          await _appState.setDarkModeEnabled(!_appState.darkModeEnabled);
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.vibration_rounded,
                        title: 'Titreşim Yoğunluğu',
                        subtitle: _appState.vibrationIntensity,
                        onTap: () => _editVibration(context),
                      ),

                      const SizedBox(height: 32),
                      _SectionTitle('Hesap'),
                      const SizedBox(height: 12),

                      _SettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Bağlantıyı kes',
                        subtitle: 'Partner bağlantısını sıfırla',
                        isDestructive: true,
                        onTap: () => _confirmDisconnect(context),
                      ),
                      _SettingsTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Tüm verileri sil',
                        subtitle: 'Geri alınamaz işlem',
                        isDestructive: true,
                        onTap: () => _confirmClearAll(context),
                      ),

                      const SizedBox(height: 48),
                      const Center(
                        child: Text(
                          'HeartSync v1.0.0 · Sevgiyle yapıldı 💕',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300, color: SyncColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editName(BuildContext context, {required bool isMe}) async {
    final controller = TextEditingController(
      text: isMe ? _appState.myName : _appState.partnerName,
    );
    final title = isMe ? 'Adını değiştir' : 'Partner adını değiştir';

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _EditDialog(title: title, controller: controller),
    );

    if (result != null && result.trim().isNotEmpty) {
      if (isMe) {
        await _appState.setMyName(result.trim());
      } else {
        await _appState.setPartnerName(result.trim());
      }
    }
  }

  Future<void> _editTimezone(BuildContext context, {required bool isMe}) async {
    final timezones = [
      'Europe/Istanbul',
      'Europe/London',
      'Europe/Paris',
      'Europe/Berlin',
      'America/New_York',
      'America/Los_Angeles',
      'America/Chicago',
      'Asia/Tokyo',
      'Asia/Seoul',
      'Asia/Dubai',
      'Asia/Singapore',
      'Australia/Sydney',
      'Pacific/Auckland',
    ];

    final current = isMe ? _appState.myTimezone : _appState.partnerTimezone;
    final title = isMe ? 'Senin saat dilimin' : '${_appState.partnerName}\'in saat dilimi';

    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SyncColors.surface,
        title: Text(title, style: GoogleFonts.syne(color: Colors.white, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: timezones.length,
            itemBuilder: (ctx, i) {
              final tz = timezones[i];
              return ListTile(
                title: Text(tz, style: TextStyle(color: tz == current ? SyncColors.coral : Colors.white, fontSize: 14)),
                trailing: tz == current ? const Icon(Icons.check_rounded, color: SyncColors.coral, size: 16) : null,
                onTap: () => Navigator.pop(ctx, tz),
              );
            },
          ),
        ),
      ),
    );

    if (picked != null) {
      if (isMe) {
        await _appState.setMyTimezone(picked);
      } else {
        await _appState.setPartnerTimezone(picked);
      }
    }
  }

  Future<void> _editVibration(BuildContext context) async {
    final options = ['Kapalı', 'Düşük', 'Orta', 'Yüksek'];
    final current = _appState.vibrationIntensity;

    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SyncColors.surface,
        title: Text('Titreşim Yoğunluğu', style: GoogleFonts.syne(color: Colors.white, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (ctx, i) {
              final val = options[i];
              return ListTile(
                title: Text(val, style: TextStyle(color: val == current ? SyncColors.coral : Colors.white, fontSize: 14)),
                trailing: val == current ? const Icon(Icons.check_rounded, color: SyncColors.coral, size: 16) : null,
                onTap: () => Navigator.pop(ctx, val),
              );
            },
          ),
        ),
      ),
    );

    if (picked != null) {
      await _appState.setVibrationIntensity(picked);
    }
  }


  Future<void> _confirmDisconnect(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SyncColors.surface,
        title: Text('Bağlantıyı Kes', style: GoogleFonts.syne(color: Colors.white)),
        content: const Text('Partner bağlantını sıfırlamak istediğine emin misin?', style: TextStyle(color: SyncColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç', style: TextStyle(color: SyncColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kes'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _appState.disconnect();
      if (context.mounted) {
        // Clear all routes and go back to Splash (the very first screen)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SyncColors.surface,
        title: Text('Tüm Verileri Sil', style: GoogleFonts.syne(color: Colors.white)),
        content: const Text('Bu işlem geri alınamaz. Tüm kişisel veriler silinecek.', style: TextStyle(color: SyncColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç', style: TextStyle(color: SyncColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await PersistenceService().clearAll();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: SyncColors.textSecondary,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : Colors.white;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: SyncColors.glassSurface,
        leading: Icon(icon, color: isDestructive ? Colors.redAccent : SyncColors.coral, size: 20),
        title: Text(title, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: SyncColors.textSecondary, fontSize: 12)),
        trailing: isDestructive
            ? null
            : const Icon(Icons.chevron_right_rounded, color: SyncColors.textSecondary, size: 18),
        onTap: onTap,
      ),
    );
  }
}

class _EditDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const _EditDialog({required this.title, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SyncColors.surface,
      title: Text(title, style: GoogleFonts.syne(color: Colors.white, fontSize: 16)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Adı girin...',
          hintStyle: TextStyle(color: SyncColors.textSecondary),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: SyncColors.glassBorder)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SyncColors.coral)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: SyncColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: SyncColors.coral),
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
