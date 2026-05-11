import 'package:flutter/material.dart';
import '../../domain/entities/device.dart';

/// Tarjeta de clima con días de la semana (Frame Home, columna izquierda).
class WeatherCard extends StatelessWidget {
  final Device device;

  const WeatherCard({super.key, required this.device});

  static const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Text('Clima',
              style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 4),
          Text(device.weather,
              style: tt.displayMedium?.copyWith(color: Colors.black)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days
                .map((d) => Flexible(child: _DayCell(label: d)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String label;
  const _DayCell({required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF3E5249),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.light_mode, color: Colors.white, size: 18),
          const SizedBox(height: 4),
          Text(label,
              style: tt.bodyMedium?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
