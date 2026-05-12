import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/device.dart';

class ActiveDeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback? onStartIrrigation;
  final VoidCallback? onStopIrrigation;

  const ActiveDeviceCard({
    super.key,
    required this.device,
    this.onStartIrrigation,
    this.onStopIrrigation,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF94BC9A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.48)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('activeDevice'),
                      style: tt.bodyMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      device.name,
                      style: tt.headlineMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _ConnectionBadge(status: device.status),
            ],
          ),
          const SizedBox(height: 20),
          _StatusChips(device: device),
        ],
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  final DeviceStatus status;

  const _ConnectionBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final online = status == DeviceStatus.online;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF43574A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            online ? Icons.wifi : Icons.wifi_off,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            online ? l10n.t('online') : l10n.t('offline'),
            style: tt.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChips extends StatelessWidget {
  final Device device;

  const _StatusChips({required this.device});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _Chip(icon: Icons.location_on_outlined, label: device.location),
        _Chip(
          icon: Icons.thermostat_outlined,
          label: l10n.temperature(device.temperatureC),
        ),
        _Chip(
          icon: Icons.water_drop_outlined,
          label: '${l10n.t('humidity')} ${device.humidityPct}%',
        ),
        _Chip(icon: Icons.eco_outlined, label: l10n.plants(device.plantCount)),
        _Chip(
          icon: Icons.battery_3_bar,
          label: '${l10n.t('battery')} ${device.batteryPct}%',
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF43574A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 7),
          Text(
            label,
            style: tt.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
