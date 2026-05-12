import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

enum SidebarItem { home, devices, analysis, history, profile, settings }

class AppSidebar extends StatelessWidget {
  final SidebarItem activeItem;
  final ValueChanged<SidebarItem>? onItemTap;

  const AppSidebar({super.key, required this.activeItem, this.onItemTap});

  static const _items = [
    (SidebarItem.home, Icons.home_outlined, 'navHome'),
    (SidebarItem.devices, Icons.devices_outlined, 'navDevices'),
    (SidebarItem.analysis, Icons.bar_chart_outlined, 'navAnalysis'),
    (SidebarItem.history, Icons.description_outlined, 'navHistory'),
    (SidebarItem.profile, Icons.person_outline, 'navProfile'),
    (SidebarItem.settings, Icons.settings_outlined, 'navSettings'),
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
          right: BorderSide(color: cs.outline.withValues(alpha: 0.32)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 34),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SizedBox(
              height: 92,
              child: Image.asset(
                AppConstants.imgAquaSaveLogo,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Divider(color: cs.outline.withValues(alpha: 0.4), height: 1),
          const SizedBox(height: AppDimensions.spaceMd),
          ..._items.map((entry) {
            final (item, icon, labelKey) = entry;
            return _SidebarRow(
              icon: icon,
              label: l10n.t(labelKey),
              isActive: item == activeItem,
              textStyle: tt.titleMedium,
              onTap: onItemTap != null ? () => onItemTap!(item) : null,
            );
          }),
        ],
      ),
    );
  }
}

class _SidebarRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  const _SidebarRow({
    required this.icon,
    required this.label,
    required this.isActive,
    this.textStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.lightPrimary;
    const inactiveColor = Color(0xFF667069);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.13)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: AppDimensions.activeIndicatorWidth,
                height: isActive ? 38 : 0,
                decoration: const BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.radiusLg),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isActive ? activeColor : inactiveColor,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle?.copyWith(
                          color: isActive ? activeColor : inactiveColor,
                          fontWeight: isActive
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
    );
  }
}
