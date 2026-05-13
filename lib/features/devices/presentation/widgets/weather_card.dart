import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../irrigation_intelligence/domain/entities/weather_forecast.dart';
import '../../../irrigation_intelligence/presentation/bloc/weather_bloc.dart';
import '../../domain/entities/device.dart';
import '../cubit/irrigation_settings_cubit.dart';

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
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<IrrigationSettingsCubit>().state;
    final condition = forecast == null
        ? l10n.t('waitingWeather')
        : l10n.weatherCondition(forecast!.weatherCode);
    final temperature = forecast?.temperatureC ?? device.temperatureC;
    final humidity = forecast?.humidityPct ?? device.humidityPct;
    final rainProbability = forecast?.rainProbabilityPct;
    final windSpeed = forecast?.windSpeedKmh;
    final advice = resolveIrrigationAdvice(
      settings: settings,
      hasForecast: forecast != null,
      temperatureC: temperature,
      soilHumidityPct: device.avgHumidityPct,
      rainProbabilityPct: rainProbability,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _weatherIcon(forecast?.weatherCode),
                  color: cs.primary,
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
                        color: cs.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      forecast?.locationName ??
                          device.localizedLocation(l10n.locale.languageCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: cs.primary,
                  ),
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
                icon: Icons.water_drop_rounded,
                label: l10n.t('humidity'),
                value: '$humidity%',
              ),
              _MetricPill(
                icon: Icons.umbrella_rounded,
                label: l10n.t('rain'),
                value: rainProbability == null ? '--' : '$rainProbability%',
              ),
              _MetricPill(
                icon: Icons.air_rounded,
                label: l10n.t('wind'),
                value: windSpeed == null ? '--' : '${windSpeed.round()} km/h',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _IrrigationAdviceCard(advice: advice),
        ],
      ),
    );
  }

  IconData _weatherIcon(int? code) {
    if (code == null || code == 0) return Icons.wb_sunny_rounded;
    if ([1, 2, 3, 45, 48].contains(code)) return Icons.cloud_rounded;
    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      return Icons.water_drop_rounded;
    }
    if ([95, 96, 99].contains(code)) return Icons.thunderstorm_rounded;
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
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.temperature(temperature),
          style: tt.displayLarge?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
            height: 0.95,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            condition,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tt.headlineSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.8),
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: cs.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurface),
            ),
          ),
        ],
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cs.primary, size: 17),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _IrrigationAdviceCard extends StatelessWidget {
  final IrrigationAdvice advice;

  const _IrrigationAdviceCard({required this.advice});

  ({Color accent, IconData icon}) _style() {
    switch (advice.kind) {
      case IrrigationAdviceKind.rainPause:
      case IrrigationAdviceKind.soilSoaked:
        return (
          accent: const Color(0xFF5BA4D4),
          icon: Icons.water_rounded,
        );
      case IrrigationAdviceKind.heatBoost:
        return (
          accent: const Color(0xFFD08A55),
          icon: Icons.local_fire_department_rounded,
        );
      case IrrigationAdviceKind.coldHold:
        return (
          accent: const Color(0xFF7AA9D6),
          icon: Icons.ac_unit_rounded,
        );
      case IrrigationAdviceKind.lowMoisture:
        return (
          accent: const Color(0xFFE17A8C),
          icon: Icons.warning_amber_rounded,
        );
      case IrrigationAdviceKind.waiting:
        return (
          accent: const Color(0xFF9AA59B),
          icon: Icons.hourglass_empty_rounded,
        );
      case IrrigationAdviceKind.ok:
        return (
          accent: const Color(0xFF6FBC85),
          icon: Icons.check_circle_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final style = _style();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: style.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: style.accent.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: style.accent.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(style.icon, color: style.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t(advice.key),
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (advice.detailKey != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.t(advice.detailKey!),
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.72),
                      height: 1.35,
                    ),
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
