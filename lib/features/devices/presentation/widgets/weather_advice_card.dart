import 'package:flutter/material.dart';

import '../../../irrigation_intelligence/domain/entities/weather_forecast.dart';

/// Recomendación/advertencia de riego según el clima (único uso del
/// pronóstico en la app). Se muestra en Inicio y en Análisis.
class WeatherAdviceCard extends StatelessWidget {
  final WeatherForecast? forecast;

  const WeatherAdviceCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final f = forecast;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final IconData icon;
    final Color color;
    final String title;
    final String body;

    if (f == null) {
      icon = Icons.cloud_off_rounded;
      color = const Color(0xFF8C9A86);
      title = 'Recomendación de riego';
      body =
          'Obteniendo el clima de tu zona… Si esto no cambia, verifica que '
          'el huerto tenga una ubicación válida (Editar huerto).';
    } else if (f.shouldPauseIrrigation) {
      icon = Icons.umbrella_rounded;
      color = const Color(0xFF5F8FA0);
      title = 'Pausa de riego recomendada';
      body =
          'Hay ${f.rainProbabilityPct}% de probabilidad de lluvia en '
          '${f.locationName}. Deja que la lluvia riegue por ti y ahorra agua.';
    } else if (f.temperatureC >= 30 && f.humidityPct <= 40) {
      icon = Icons.local_fire_department_rounded;
      color = const Color(0xFFCB7C46);
      title = 'Riego recomendado';
      body =
          'Hace ${f.temperatureC.toStringAsFixed(0)}°C con aire seco '
          '(${f.humidityPct}%): tus plantas perderán agua rápido hoy.';
    } else {
      icon = Icons.check_circle_outline_rounded;
      color = const Color(0xFF5FA06E);
      title = 'Clima estable';
      body =
          '${f.conditionLabel} en ${f.locationName}. No se necesitan '
          'ajustes: tu plan de riego actual es adecuado.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.75),
                    height: 1.35,
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
