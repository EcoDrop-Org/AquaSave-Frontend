import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_dimensions.dart';
import 'app_logo.dart';

enum SidebarItem { home, devices, analysis, history, profile, settings }

class AppSidebar extends StatelessWidget {
  final SidebarItem activeItem;
  final ValueChanged<SidebarItem>? onItemTap;

  const AppSidebar({super.key, required this.activeItem, this.onItemTap});

  static const _items = [
    (SidebarItem.home, Icons.home_rounded, Icons.home_outlined, 'navHome'),
    (
      SidebarItem.devices,
      Icons.devices_rounded,
      Icons.devices_outlined,
      'navDevices',
    ),
    (
      SidebarItem.analysis,
      Icons.bar_chart_rounded,
      Icons.bar_chart_outlined,
      'navAnalysis',
    ),
    (
      SidebarItem.history,
      Icons.description_rounded,
      Icons.description_outlined,
      'navHistory',
    ),
    (
      SidebarItem.profile,
      Icons.person_rounded,
      Icons.person_outline,
      'navProfile',
    ),
    (
      SidebarItem.settings,
      Icons.settings_rounded,
      Icons.settings_outlined,
      'navSettings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: AppDimensions.sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(color: cs.outline.withValues(alpha: 0.30)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SizedBox(height: 86, child: AppLogo(fit: BoxFit.contain)),
          ),
          const SizedBox(height: 22),
          Divider(
            color: cs.outline.withValues(alpha: 0.32),
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          ..._items.map((entry) {
            final (item, activeIcon, icon, labelKey) = entry;
            return _SidebarRow(
              icon: icon,
              activeIcon: activeIcon,
              label: l10n.t(labelKey),
              isActive: item == activeItem,
              textStyle: tt.titleMedium,
              onTap: onItemTap != null ? () => onItemTap!(item) : null,
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SidebarRow extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  const _SidebarRow({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    this.textStyle,
    this.onTap,
  });

  @override
  State<_SidebarRow> createState() => _SidebarRowState();
}

class _SidebarRowState extends State<_SidebarRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = cs.primary;
    final inactive = cs.onSurface.withValues(alpha: 0.62);
    final highlighted = widget.isActive || _hovered;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: widget.isActive
                  ? active.withValues(alpha: 0.14)
                  : _hovered
                  ? active.withValues(alpha: 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: AppDimensions.activeIndicatorWidth,
                  height: widget.isActive ? 32 : 0,
                  decoration: BoxDecoration(
                    color: active,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(AppDimensions.radiusLg),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.isActive ? widget.activeIcon : widget.icon,
                        color: highlighted ? active : inactive,
                        size: 23,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.label,
                          overflow: TextOverflow.ellipsis,
                          style: widget.textStyle?.copyWith(
                            color: highlighted ? active : inactive,
                            fontWeight: widget.isActive
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
