import 'package:flutter/material.dart';
import '../../domain/entities/device.dart';

/// Tarjeta principal verde oscura del dispositivo activo (Frame Home).
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF94BC9A),
        borderRadius: BorderRadius.circular(46),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dispositivo activo',
              style: tt.displayMedium?.copyWith(color: Colors.black)),
          const SizedBox(height: 4),
          Text(device.name,
              style: tt.displayMedium?.copyWith(color: Colors.black)),
          const SizedBox(height: 24),
          _StatusChips(device: device),
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
    final tt = Theme.of(context).textTheme;
    const chipBg = Color(0xFF43574A);
    final chipStyle = tt.bodyMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w300,
    );

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _Chip(
          icon: Icons.location_on_outlined,
          label: device.location,
          bg: chipBg,
          style: chipStyle,
        ),
        _Chip(
          icon: Icons.wifi,
          label: device.status == DeviceStatus.online ? 'En línea' : 'Sin conexión',
          bg: chipBg,
          style: chipStyle,
        ),
        _Chip(
          icon: Icons.thermostat_outlined,
          label: '${device.temperatureC.toStringAsFixed(0)}°C',
          bg: chipBg,
          style: chipStyle,
        ),
        _Chip(
          icon: Icons.water_drop_outlined,
          label: 'Humedad ${device.humidityPct}%',
          bg: chipBg,
          style: chipStyle,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final TextStyle? style;

  const _Chip({
    required this.icon,
    required this.label,
    required this.bg,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(label, style: style),
        ],
      ),
    );
  }
}
