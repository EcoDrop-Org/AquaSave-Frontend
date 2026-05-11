import 'package:flutter/material.dart';
import '../../domain/entities/device.dart';

/// Tarjeta de humedad promedio con slider visual (Frame Home, columna derecha).
class HumidityCard extends StatelessWidget {
  final Device device;

  const HumidityCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final value = device.avgHumidityPct / 100.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFC7DEC3),
        borderRadius: BorderRadius.circular(32),
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
          Text('Humedad Promedio',
              style: tt.displayMedium?.copyWith(color: Colors.black)),
          const SizedBox(height: 12),
          Text('${device.avgHumidityPct}%',
              style: tt.displayMedium?.copyWith(color: Colors.black)),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF2D3D2C),
              inactiveTrackColor: const Color(0xFFC7DEC3),
              thumbColor: const Color(0xFF2D3D2C),
              overlayColor: Colors.transparent,
              trackHeight: 3,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              onChanged: null, // solo lectura
            ),
          ),
        ],
      ),
    );
  }
}
