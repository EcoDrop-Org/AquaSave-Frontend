import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/bloc/user_segment_context.dart';
import '../../../irrigation_intelligence/domain/entities/weather_forecast.dart';

/// Recomendación/advertencia de riego según el clima (único uso del
/// pronóstico en la app). Se muestra en Inicio y en Análisis.
///
/// El texto se adapta al segmento (informe 1.3): al principiante se le explica
/// qué significa la lectura y qué hacer; al experto se le dan las cifras que
/// necesita para decidir por su cuenta.
class WeatherAdviceCard extends StatelessWidget {
  final WeatherForecast? forecast;

  const WeatherAdviceCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final f = forecast;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isBeginner = context.isBeginnerUser;

    final IconData icon;
    final Color color;
    final String title;
    final String body;

    if (f == null) {
      icon = Icons.cloud_off_rounded;
      color = AppColors.sage;
      title = 'Recomendación de riego';
      body =
          'Obteniendo el clima de tu zona… Si esto no cambia, verifica que '
          'tu planta tenga una ubicación válida (Editar planta).';
    } else if (f.shouldPauseIrrigation) {
      icon = Icons.umbrella_rounded;
      color = AppColors.sky;
      title = 'Pausa de riego recomendada';
      body = isBeginner
          ? 'Hay ${f.rainProbabilityPct}% de probabilidad de lluvia en '
                '${f.locationName}. Deja que la lluvia riegue por ti y '
                'ahorra agua: no hace falta que riegues hoy.'
          : 'Lluvia ${f.rainProbabilityPct}% · '
                '${f.precipitationMm.toStringAsFixed(1)} mm en '
                '${f.locationName}. Conviene posponer el riego.';
    } else if (f.temperatureC >= 30 && f.humidityPct <= 40) {
      icon = Icons.local_fire_department_rounded;
      color = AppColors.earth;
      title = 'Riego recomendado';
      body = isBeginner
          ? 'Hace ${f.temperatureC.toStringAsFixed(0)}°C con aire seco '
                '(${f.humidityPct}%): tus plantas perderán agua rápido hoy. '
                'Revisa la humedad del suelo y riega si está baja.'
          : '${f.temperatureC.toStringAsFixed(1)}°C · HR ${f.humidityPct}% · '
                'viento ${f.windSpeedKmh.toStringAsFixed(0)} km/h. '
                'Demanda hídrica alta.';
    } else {
      icon = Icons.check_circle_outline_rounded;
      color = AppColors.leaf;
      title = 'Clima estable';
      body = isBeginner
          ? '${f.conditionLabel} en ${f.locationName}. No se necesitan '
                'ajustes: tu plan de riego actual es adecuado.'
          : '${f.conditionLabel} · ${f.temperatureC.toStringAsFixed(1)}°C · '
                'HR ${f.humidityPct}% · lluvia ${f.rainProbabilityPct}% '
                'en ${f.locationName}.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
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
                // El backend responde 20 °C cuando el proveedor de clima falla
                // (timeout o cuota diaria agotada). Sin este aviso el usuario
                // lo lee como una medición real.
                if (f != null && f.isEstimated) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 15,
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Valores estimados: no pudimos consultar el clima '
                          'de tu zona. Se actualizarán solos en unos minutos.',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.55),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
