import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/device.dart';
import '../bloc/devices_bloc.dart';

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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F7A5C), Color(0xFF35513F)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.sensors_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('activeDevice').toUpperCase(),
                      style: tt.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _ConnectionBadge(status: device.status),
            ],
          ),
          const SizedBox(height: 24),
          _BigStats(device: device),
          const SizedBox(height: 18),
          _FooterChips(device: device),
          const SizedBox(height: 14),
          _PauseControl(device: device),
        ],
      ),
    );
  }
}

/// Apagado/encendido remoto del riego: en pausa, la bomba se apaga y el
/// dispositivo no riega (ni automatico ni manual) hasta reactivarlo. El
/// dispositivo sigue conectado y reportando para poder volver a encenderlo.
class _PauseControl extends StatelessWidget {
  final Device device;

  const _PauseControl({required this.device});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final paused = !device.isActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: paused
            ? const Color(0xFFC0A24A).withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: paused
              ? const Color(0xFFE8CD7A)
              : Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            paused ? Icons.pause_circle_outline_rounded : Icons.power_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              paused
                  ? 'Dispositivo en pausa: no regará hasta reactivarlo'
                  : 'Dispositivo activo',
              style: tt.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: !paused,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFCBE7A3).withValues(alpha: 0.6),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.black.withValues(alpha: 0.25),
            onChanged: (active) {
              context.read<DevicesBloc>().add(
                ToggleDevicePause(deviceId: device.id, paused: !active),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    active
                        ? 'Reactivando dispositivo…'
                        : 'Pausando dispositivo…',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Datos principales del dispositivo en grande: humedad del suelo (con barra),
/// temperatura y cantidad de plantas.
class _BigStats extends StatelessWidget {
  final Device device;

  const _BigStats({required this.device});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 560;

        final humidity = _BigStat(
          icon: Icons.water_drop_rounded,
          label: l10n.t('humidity'),
          value: '${device.humidityPct}%',
          progress: (device.humidityPct / 100).clamp(0.0, 1.0),
        );
        final temperature = _BigStat(
          icon: Icons.thermostat_rounded,
          label: l10n.t('temperature'),
          value: device.temperatureC == 0
              ? '—'
              : l10n.temperature(device.temperatureC),
        );
        final plants = _BigStat(
          icon: Icons.eco_rounded,
          label: l10n.t('plantsLabel'),
          value: '${device.plantCount}',
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: humidity),
              const SizedBox(width: 14),
              Expanded(flex: 3, child: temperature),
              const SizedBox(width: 14),
              Expanded(flex: 3, child: plants),
            ],
          );
        }

        return Column(
          children: [
            humidity,
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: temperature),
                const SizedBox(width: 12),
                Expanded(child: plants),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _BigStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double? progress;

  const _BigStat({
    required this.icon,
    required this.label,
    required this.value,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress,
                color: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ubicación del huerto como chip secundario bajo los datos grandes.
class _FooterChips extends StatelessWidget {
  final Device device;

  const _FooterChips({required this.device});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _Chip(
          icon: Icons.place_outlined,
          label: device.localizedLocation(l10n.locale.languageCode),
        ),
      ],
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            online ? l10n.t('online') : l10n.t('offline'),
            style: tt.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
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
