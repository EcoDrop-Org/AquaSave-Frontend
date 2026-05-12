import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../irrigation_intelligence/domain/entities/weather_forecast.dart';
import '../../../irrigation_intelligence/presentation/bloc/weather_bloc.dart';
import '../../domain/entities/device.dart';

class WeatherCard extends StatelessWidget {
  final Device device;

  const WeatherCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        final forecast =
            state is WeatherLoaded && state.forecast.deviceId == device.id
            ? state.forecast
            : null;
        final isLoading =
            state is WeatherLoading && state.deviceId == device.id;
        final error =
            state is WeatherFailureState && state.deviceId == device.id
            ? state.message
            : null;

        return _WeatherCardContent(
          device: device,
          forecast: forecast,
          isLoading: isLoading,
          error: error,
        );
      },
    );
  }
}

class _WeatherCardContent extends StatelessWidget {
  final Device device;
  final WeatherForecast? forecast;
  final bool isLoading;
  final String? error;

  const _WeatherCardContent({
    required this.device,
    required this.forecast,
    required this.isLoading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final condition = forecast == null
        ? l10n.t('waitingWeather')
        : l10n.weatherCondition(forecast!.weatherCode);
    final temperature = forecast?.temperatureC ?? device.temperatureC;
    final humidity = forecast?.humidityPct ?? device.humidityPct;
    final rainProbability = forecast?.rainProbabilityPct;
    final windSpeed = forecast?.windSpeedKmh;
    final shouldPause = forecast?.shouldPauseIrrigation ?? false;
    final shouldAskForWater =
        forecast != null &&
        !shouldPause &&
        temperature >= 28 &&
        device.avgHumidityPct <= 35;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFC7DEC3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.56)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 16,
            offset: const Offset(0, 9),
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
                child: Icon(
                  _weatherIcon(forecast?.weatherCode),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('weatherGarden'),
                      style: tt.bodyMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.68),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      forecast?.locationName ?? device.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(
                        color: Colors.black.withValues(alpha: 0.58),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: error == null
                ? _WeatherSummary(
                    key: ValueKey(condition),
                    condition: condition,
                    temperature: temperature,
                  )
                : _WeatherError(message: error!),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(
                icon: Icons.water_drop_outlined,
                label: l10n.t('humidity'),
                value: '$humidity%',
              ),
              _MetricPill(
                icon: Icons.umbrella_outlined,
                label: l10n.t('rain'),
                value: rainProbability == null ? '--' : '$rainProbability%',
              ),
              _MetricPill(
                icon: Icons.air,
                label: l10n.t('wind'),
                value: windSpeed == null ? '--' : '${windSpeed.round()} km/h',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _IrrigationAdvice(
            shouldPause: shouldPause,
            shouldAskForWater: shouldAskForWater,
            hasForecast: forecast != null,
          ),
        ],
      ),
    );
  }

  IconData _weatherIcon(int? code) {
    if (code == null || code == 0) return Icons.wb_sunny_outlined;
    if ([1, 2, 3, 45, 48].contains(code)) return Icons.cloud_queue;
    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      return Icons.water_drop_outlined;
    }
    if ([95, 96, 99].contains(code)) return Icons.thunderstorm_outlined;
    return Icons.cloud_outlined;
  }
}

class _WeatherSummary extends StatelessWidget {
  final String condition;
  final double temperature;

  const _WeatherSummary({
    super.key,
    required this.condition,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Text(
          l10n.temperature(temperature),
          style: tt.displayLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            height: 0.95,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            condition,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tt.headlineMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeatherError extends StatelessWidget {
  final String message;

  const _WeatherError({required this.message});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: tt.bodyMedium?.copyWith(color: const Color(0xFF2D3D2C)),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3E5249),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 7),
          Text(
            '$label ',
            style: tt.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
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

class _IrrigationAdvice extends StatelessWidget {
  final bool shouldPause;
  final bool shouldAskForWater;
  final bool hasForecast;

  const _IrrigationAdvice({
    required this.shouldPause,
    required this.shouldAskForWater,
    required this.hasForecast,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final bg = shouldPause
        ? const Color(0xFFFE5C73)
        : shouldAskForWater
        ? const Color(0xFFB8642B)
        : const Color(0xFF497654);
    final text = !hasForecast
        ? l10n.t('waitingWeather')
        : shouldPause
        ? l10n.t('pauseIrrigation')
        : shouldAskForWater
        ? l10n.t('waterRecommended')
        : l10n.t('continueIrrigation');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bg.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(
            shouldPause
                ? Icons.pause_circle_outline
                : shouldAskForWater
                ? Icons.local_fire_department_outlined
                : Icons.check_circle_outline,
            color: bg,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: tt.bodyMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
