import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Índices del sidebar — úsalos en cada pantalla para marcar el ítem activo.
enum SidebarItem { home, devices, analysis, history, profile, settings }

/// Sidebar de navegación lateral reutilizable.
/// Pásale [activeItem] para resaltar el ítem correcto en cada pantalla.
/// [onItemTap] es opcional — úsalo para navegar entre secciones.
class AppSidebar extends StatelessWidget {
  final SidebarItem activeItem;
  final ValueChanged<SidebarItem>? onItemTap;

  const AppSidebar({super.key, required this.activeItem, this.onItemTap});

  static const _items = [
    (SidebarItem.home, Icons.home_outlined, AppConstants.navHome),
    (SidebarItem.devices, Icons.devices_outlined, AppConstants.navDevices),
    (SidebarItem.analysis, Icons.bar_chart_outlined, AppConstants.navAnalysis),
    (SidebarItem.history, Icons.description_outlined, AppConstants.navHistory),
    (SidebarItem.profile, Icons.person_outline, AppConstants.navProfile),
    (SidebarItem.settings, Icons.settings_outlined, AppConstants.navSettings),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: AppDimensions.sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 92,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.36),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outline.withValues(alpha: 0.22)),
              ),
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
            final (item, icon, label) = entry;
            final isActive = item == activeItem;
            return _SidebarRow(
              icon: icon,
              label: label,
              isActive: isActive,
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
    const inactiveColor = Color(0xFF767575);

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
                ? activeColor.withValues(alpha: 0.12)
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
                              ? FontWeight.w700
                              : FontWeight.w500,
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
