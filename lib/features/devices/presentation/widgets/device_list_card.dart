import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/device.dart';

class DeviceListCard extends StatelessWidget {
  final Device device;
  final VoidCallback? onViewDetails;
  final VoidCallback? onEdit;
  final bool isActive;

  const DeviceListCard({
    super.key,
    required this.device,
    this.onViewDetails,
    this.onEdit,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final online = device.status == DeviceStatus.online;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF94BC9A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive
              ? const Color(0xFF2D3D2C)
              : const Color(0xFF37593F).withValues(alpha: 0.4),
          width: isActive ? 2 : 1,
        ),
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
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E5C48),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sensors, color: Colors.white, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      device.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(
                        color: Colors.black.withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(online: online, isActive: isActive),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _CompactStat(
                  icon: Icons.eco_outlined,
                  value: '${device.plantCount}',
                  label: l10n.t('plantsLabel'),
                ),
              ),
              Expanded(
                child: _CompactStat(
                  icon: Icons.water_drop_outlined,
                  value: '${device.avgHumidityPct}%',
                  label: l10n.t('humidity'),
                ),
              ),
              Expanded(
                child: _CompactStat(
                  icon: Icons.battery_3_bar,
                  value: '${device.batteryPct}%',
                  label: l10n.t('battery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(
                    l10n.t('viewDeviceData'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E5C48),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _IconActionButton(
                icon: Icons.edit_outlined,
                tooltip: l10n.t('editDevice'),
                onPressed: onEdit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool online;
  final bool isActive;

  const _StatusBadge({required this.online, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            isActive
                ? l10n.t('active')
                : online
                ? l10n.t('online')
                : l10n.t('offline'),
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

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
            ),
            child: Icon(icon, color: const Color(0xFF2D3D2C), size: 20),
          ),
        ),
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _CompactStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2D3D2C), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: tt.titleMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: tt.bodySmall?.copyWith(
            color: Colors.black.withValues(alpha: 0.58),
          ),
        ),
      ],
    );
  }
}
