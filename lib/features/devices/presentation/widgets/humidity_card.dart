import 'package:flutter/material.dart';

import '../../domain/entities/device.dart';

class HumidityCard extends StatelessWidget {
  final Device device;

  const HumidityCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final value = device.avgHumidityPct / 100.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFC7DEC3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.56)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E5249),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Humedad promedio',
                  style: tt.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(animatedValue * 100).round()}%',
                    style: tt.displayLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 12,
                      value: animatedValue,
                      color: const Color(0xFF2D3D2C),
                      backgroundColor: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Rango objetivo para mantener el cultivo saludable.',
            style: tt.bodySmall?.copyWith(
              color: Colors.black.withValues(alpha: 0.58),
            ),
          ),
        ],
      ),
    );
  }
}
