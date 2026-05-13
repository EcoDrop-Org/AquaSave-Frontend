import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/device.dart';

class DeviceListCard extends StatefulWidget {
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
  State<DeviceListCard> createState() => _DeviceListCardState();
}

class _DeviceListCardState extends State<DeviceListCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final online = widget.device.status == DeviceStatus.online;
    final cardColor = isDark
        ? cs.primary.withValues(alpha: 0.16)
        : cs.primary.withValues(alpha: 0.46);
    final inkColor = isDark
        ? cs.primary.withValues(alpha: 0.24)
        : cs.primary.withValues(alpha: 0.58);
    final titleColor = isDark ? cs.onSurface : const Color(0xFF0E180F);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        scale: _hovered ? 1.012 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 236),
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          decoration: BoxDecoration(
            color: _hovered ? inkColor : cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.isActive
                  ? cs.primary.withValues(alpha: 0.72)
                  : cs.primary.withValues(alpha: 0.18),
              width: widget.isActive ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.16 : 0.10),
                blurRadius: _hovered ? 28 : 20,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: _StatusPill(online: online, isActive: widget.isActive),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 285),
                    child: Text(
                      widget.device.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: tt.headlineSmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 220,
                    height: 2,
                    decoration: BoxDecoration(
                      color: titleColor.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 22,
                    runSpacing: 12,
                    children: [
                      _InlineStat(
                        icon: Icons.eco_rounded,
                        value: '${widget.device.plantCount}',
                        label: l10n.t('plantsLabel'),
                      ),
                      _InlineStat(
                        icon: Icons.water_drop_rounded,
                        value: '${widget.device.avgHumidityPct}%',
                        label: l10n.t('humidity'),
                      ),
                      _InlineStat(
                        icon: Icons.battery_5_bar_rounded,
                        value: '${widget.device.batteryPct}%',
                        label: l10n.t('battery'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onViewDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E5548),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.t('viewDetails'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: Text(l10n.t('editDevice')),
                    style: TextButton.styleFrom(
                      foregroundColor: titleColor.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool online;
  final bool isActive;

  const _StatusPill({required this.online, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = online ? l10n.t('online') : l10n.t('offline');
    final icon = online ? Icons.wifi_rounded : Icons.wifi_off_rounded;
    final bg = online
        ? const Color(0xFF3E5548)
        : Theme.of(context).colorScheme.error;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isActive ? 0.20 : 0.14),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InlineStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fg = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurface
        : Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: fg),
        const SizedBox(width: 7),
        Text(
          '$value $label',
          style: tt.bodyMedium?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
