import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_localizations.dart';
import '../../features/devices/presentation/bloc/devices_bloc.dart';
import '../../features/devices/presentation/bloc/irrigation_cubit.dart';
import '../../features/irrigation_intelligence/presentation/bloc/weather_bloc.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final alerts = _buildAlerts(context, l10n);
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: l10n.t('notifications'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showNotifications(context, alerts),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: alerts.isEmpty
                  ? cs.surfaceContainerHighest.withValues(alpha: 0.86)
                  : cs.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: alerts.isEmpty
                    ? cs.outline.withValues(alpha: 0.20)
                    : cs.primary.withValues(alpha: 0.30),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  alerts.isEmpty
                      ? Icons.notifications_outlined
                      : Icons.notifications_active_outlined,
                  color: alerts.isEmpty ? cs.onSurface : cs.primary,
                  size: 22,
                ),
                if (alerts.isNotEmpty)
                  Positioned(
                    right: 7,
                    top: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE5C73),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: cs.surface, width: 1.5),
                      ),
                      child: Text(
                        '${alerts.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_AlertItem> _buildAlerts(BuildContext context, AppLocalizations l10n) {
    final alerts = <_AlertItem>[];
    final irrigationState = context.watch<IrrigationCubit>().state;
    final devicesState = context.watch<DevicesBloc>().state;
    final weatherState = context.watch<WeatherBloc>().state;

    if (irrigationState.isIrrigating) {
      alerts.add(
        _AlertItem(
          icon: Icons.opacity,
          title: l10n.t('irrigationActiveNotice'),
          body: l10n.t('irrigationActiveBody'),
          color: const Color(0xFF497654),
        ),
      );
    }

    if (weatherState is WeatherLoaded &&
        weatherState.forecast.shouldPauseIrrigation) {
      alerts.add(
        _AlertItem(
          icon: Icons.umbrella_outlined,
          title: l10n.t('weatherPauseNotice'),
          body: l10n.t('weatherPauseBody'),
          color: const Color(0xFFFE5C73),
        ),
      );
    }

    if (devicesState is DevicesLoaded && devicesState.devices.isNotEmpty) {
      final device = devicesState.activeDevice;
      final forecast =
          weatherState is WeatherLoaded &&
              weatherState.forecast.deviceId == device.id
          ? weatherState.forecast
          : null;
      final temperature = forecast?.temperatureC ?? device.temperatureC;
      final shouldAskForWater =
          temperature >= 28 && device.avgHumidityPct <= 35;

      if (shouldAskForWater) {
        alerts.add(
          _AlertItem(
            icon: Icons.local_fire_department_outlined,
            title: l10n.t('heatWaterNotice'),
            body: l10n.t('heatWaterBody'),
            color: const Color(0xFFB8642B),
          ),
        );
      }

      if (device.batteryPct <= 25) {
        alerts.add(
          _AlertItem(
            icon: Icons.battery_alert_outlined,
            title: l10n.t('batteryNotice'),
            body: '${device.name}: ${l10n.t('batteryBody')}',
            color: const Color(0xFFB8642B),
          ),
        );
      }
    }

    return alerts;
  }

  void _showNotifications(BuildContext context, List<_AlertItem> alerts) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('notificationCenter'),
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                if (alerts.isEmpty)
                  _EmptyNotifications(message: l10n.t('noNotifications'))
                else
                  ...alerts.map((alert) => _AlertTile(alert: alert)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AlertTile extends StatelessWidget {
  final _AlertItem alert;

  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: alert.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(alert.icon, color: alert.color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  alert.body,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.66),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  final String message;

  const _EmptyNotifications({required this.message});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.22)),
      ),
      child: Text(
        message,
        style: tt.bodyMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.66),
        ),
      ),
    );
  }
}

class _AlertItem {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });
}
