import 'package:flutter/material.dart';
import '../../ui/sync_colors.dart';
import '../../core/services/app_state.dart';

class PartnerContextCard extends StatelessWidget {
  const PartnerContextCard({super.key});

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoItem(icon: Icons.location_on_outlined, value: '1.240 km', label: 'Uzaklık'),
            _InfoItem(icon: Icons.wb_cloudy_outlined, value: '22°C', label: 'Hava Durumu'),
            _InfoItem(icon: Icons.access_time, value: '21:22', label: 'Yerel Saat'),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _InfoItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: SyncColors.violet, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}
