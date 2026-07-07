import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/device.dart';

class DeviceListCard extends StatefulWidget {
  final Device device;
  final VoidCallback? onViewDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onSetActive;
  final bool isActive;

  const DeviceListCard({
    super.key,
    required this.device,
    this.onViewDetails,
    this.onEdit,
    this.onSetActive,
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
    final online = widget.device.status == DeviceStatus.online;
    final isActive = widget.isActive;

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
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive
                  ? cs.primary
                  : cs.outline.withValues(alpha: _hovered ? 0.55 : 0.35),
              width: isActive ? 1.8 : 1,
            ),
            boxShadow: [
              // El huerto activo proyecta un halo verde sutil, no solo borde.
              BoxShadow(
                color: isActive
                    ? cs.primary.withValues(alpha: _hovered ? 0.30 : 0.20)
                    : Colors.black.withValues(alpha: _hovered ? 0.16 : 0.08),
                blurRadius: _hovered ? 26 : 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: icon + name/location + status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.sensors_rounded,
                      color: cs.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.device.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 13,
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.device.localizedLocation(
                                  l10n.locale.languageCode,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusPill(online: online, isActive: isActive),
                ],
              ),
              const SizedBox(height: 18),
              // Three inline stats
              Row(
                children: [
                  Expanded(
                    child: _InlineStat(
                      icon: Icons.eco_rounded,
                      accent: AppColors.leaf,
                      value: '${widget.device.plantCount}',
                      label: l10n.t('plantsLabel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InlineStat(
                      icon: Icons.water_drop_rounded,
                      accent: AppColors.aqua,
                      value: '${widget.device.avgHumidityPct}%',
                      label: l10n.t('humidity'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InlineStat(
                      icon: Icons.thermostat_rounded,
                      accent: AppColors.sun,
                      value: '${widget.device.temperatureC.round()}°C',
                      label: l10n.t('temperature'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Main action: "Activar" / "Huerto activo" + edit
              Row(
                children: [
                  Expanded(child: _ActivateButton(isActive: isActive, onPressed: widget.onSetActive)),
                  const SizedBox(width: 10),
                  _IconActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: l10n.t('editDevice'),
                    onPressed: widget.onEdit,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Secondary: open detail dialog
              Center(
                child: TextButton.icon(
                  onPressed: widget.onViewDetails,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(l10n.t('viewDetails')),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivateButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onPressed;

  const _ActivateButton({required this.isActive, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    if (isActive) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: cs.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.t('currentlyActive'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.bolt_rounded, size: 18),
      label: Text(
        l10n.t('setActive'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final Color bg;
    final Color fg;
    final IconData icon;
    final String label;
    if (online) {
      bg = AppColors.leaf.withValues(alpha: 0.14);
      fg = Theme.of(context).brightness == Brightness.dark
          ? Color.lerp(AppColors.leaf, Colors.white, 0.25)!
          : Color.lerp(AppColors.leaf, Colors.black, 0.18)!;
      icon = Icons.wifi_rounded;
      label = l10n.t('online');
    } else {
      bg = cs.error.withValues(alpha: 0.14);
      fg = cs.error;
      icon = Icons.wifi_off_rounded;
      label = l10n.t('offline');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: tt.bodySmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 12,
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
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(13),
          child: Ink(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: cs.primary.withValues(alpha: 0.24)),
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
        ),
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String value;
  final String label;

  const _InlineStat({
    required this.icon,
    required this.accent,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 19),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
