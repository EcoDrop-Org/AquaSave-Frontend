import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../irrigation_intelligence/presentation/bloc/weather_bloc.dart';
import '../../data/datasources/remote/irrigation_remote_datasource.dart';
import '../widgets/weather_advice_card.dart';
import '../bloc/devices_bloc.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final IrrigationRemoteDataSourceImpl? _remote =
      AppConstants.useMockData ? null : IrrigationRemoteDataSourceImpl();

  AnalyticsModel? _analytics;
  List<IrrigationEventModel> _events = const [];
  String? _fetchedDeviceId;

  // Trae del backend los KPIs reales (litros, riegos, duracion) y los
  // eventos (para la serie real de humedad en los ultimos riegos).
  Future<void> _fetch(String deviceId) async {
    final remote = _remote;
    if (remote == null) return;
    try {
      final analytics = await remote.getAnalytics(deviceId);
      final events = await remote.getEvents(deviceId);
      if (!mounted || _fetchedDeviceId != deviceId) return;
      setState(() {
        _analytics = analytics;
        _events = events;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _analytics = null;
        _events = const [];
      });
    }
  }

  /// Humedad del suelo registrada al iniciar los ultimos riegos (data real
  /// del backend). Vacia si aun no hay eventos con snapshot.
  List<int> _realMoistureSeries() {
    final withData =
        _events.where((event) => event.soilMoisturePct != null).toList()
          ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    final last = withData.length > 7
        ? withData.sublist(withData.length - 7)
        : withData;
    return last
        .map((event) => event.soilMoisturePct!.round().clamp(0, 100))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AppHeader(title: l10n.t('navAnalysis')),
          Expanded(
            child: BlocBuilder<DevicesBloc, DevicesState>(
              builder: (context, devicesState) {
                final hasDevice =
                    devicesState is DevicesLoaded &&
                    devicesState.devices.isNotEmpty;
                final device = hasDevice ? devicesState.activeDevice : null;

                // Refrescar analytics/eventos cuando cambia el dispositivo.
                if (device != null && device.id != _fetchedDeviceId) {
                  _fetchedDeviceId = device.id;
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _fetch(device.id),
                  );
                }

                final weatherState = context.watch<WeatherBloc>().state;
                final forecast =
                    weatherState is WeatherLoaded &&
                        weatherState.forecast.deviceId == device?.id
                    ? weatherState.forecast
                    : null;
                final temperature =
                    forecast?.temperatureC ?? device?.temperatureC ?? 24;
                final humidity = device?.avgHumidityPct ?? 0;
                final moistureSeries = _realMoistureSeries();
                final stabilityScore = _soilStabilityScore(moistureSeries);
                final waterStressAvoidedIndex = _waterStressAvoidedIndex(
                  moistureSeries,
                  temperature,
                );
                final kpis = _analytics?.kpis;
                final retention = _retentionDiagnostic(
                  l10n,
                  moistureSeries,
                  hasEnoughHistory: hasDevice && moistureSeries.length >= 6,
                );
                final screenWidth = MediaQuery.sizeOf(context).width;
                final horizontalPadding = screenWidth < 640
                    ? AppDimensions.spaceMd
                    : AppDimensions.spaceLg;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppDimensions.spaceLg,
                    horizontalPadding,
                    AppDimensions.spaceXl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.t('analyticsTitle'),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.t('analyticsSubtitle'),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.68),
                                ),
                          ),
                          const SizedBox(height: AppDimensions.spaceMd),
                          _AnalyticsHero(
                            stabilityScore: stabilityScore,
                            stabilityLabel: _stabilityLabel(
                              l10n,
                              stabilityScore,
                            ),
                            waterStressAvoidedIndex: waterStressAvoidedIndex,
                            temperature: temperature,
                            humidity: humidity,
                            hasEnoughHistory: retention.hasEnoughHistory,
                          ),
                          const SizedBox(height: AppDimensions.spaceMd),
                          // El clima (Open-Meteo) solo se usa para recomendar
                          // al usuario sobre el riego.
                          WeatherAdviceCard(forecast: forecast),
                          const SizedBox(height: AppDimensions.spaceMd),
                          // KPIs reales de los ultimos 30 dias (backend
                          // /api/irrigation/analytics).
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final wide = constraints.maxWidth >= 960;
                              final compact = constraints.maxWidth < 560;
                              final cards = [
                                _MetricCard(
                                  icon: Icons.water_drop_outlined,
                                  title: 'Agua usada (30 días)',
                                  value:
                                      '${(kpis?.totalLiters ?? 0).toStringAsFixed(1)} L',
                                  caption: 'Litros estimados por caudal',
                                  color: AppColors.aqua,
                                  compact: compact,
                                ),
                                _MetricCard(
                                  icon: Icons.today_outlined,
                                  title: 'Promedio diario',
                                  value:
                                      '${(kpis?.avgDailyLiters ?? 0).toStringAsFixed(1)} L',
                                  caption: 'Consumo medio por día',
                                  color: AppColors.leaf,
                                  compact: compact,
                                ),
                                _MetricCard(
                                  icon: Icons.water_outlined,
                                  title: 'Riegos (30 días)',
                                  value: '${kpis?.totalEvents ?? 0}',
                                  caption: 'Eventos completados',
                                  color: AppColors.sun,
                                  compact: compact,
                                ),
                                _MetricCard(
                                  icon: Icons.timer_outlined,
                                  title: 'Duración promedio',
                                  value:
                                      '${(kpis?.avgDurationMin ?? 0).toStringAsFixed(1)} min',
                                  caption: 'Por evento de riego',
                                  color: AppColors.lavender,
                                  compact: compact,
                                ),
                              ];

                              if (!wide) {
                                return Column(
                                  children: [
                                    for (final card in cards) ...[
                                      card,
                                      const SizedBox(height: 12),
                                    ],
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  for (final card in cards) ...[
                                    Expanded(child: card),
                                    if (card != cards.last)
                                      const SizedBox(
                                        width: AppDimensions.spaceMd,
                                      ),
                                  ],
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: AppDimensions.spaceMd),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final wide = constraints.maxWidth >= 900;
                              // Serie real: humedad al iniciar cada riego. Si
                              // aun no hay suficientes riegos, placeholder.
                              final Widget trendCard =
                                  moistureSeries.length >= 2
                                  ? _TrendCard(values: moistureSeries)
                                  : const _CollectingDataCard();
                              if (!wide) {
                                return Column(
                                  children: [
                                    trendCard,
                                    const SizedBox(
                                      height: AppDimensions.spaceMd,
                                    ),
                                    _RetentionCard(diagnostic: retention),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 5, child: trendCard),
                                  const SizedBox(width: AppDimensions.spaceMd),
                                  Expanded(
                                    flex: 4,
                                    child: _RetentionCard(
                                      diagnostic: retention,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _soilStabilityScore(List<int> values) {
    if (values.length < 2) return 0;

    final average = values.reduce((a, b) => a + b) / values.length;
    final averageDeviation =
        values.map((value) => (value - average).abs()).reduce((a, b) => a + b) /
        values.length;
    var jumpTotal = 0;
    for (var i = 1; i < values.length; i++) {
      jumpTotal += (values[i] - values[i - 1]).abs();
    }
    final averageJump = jumpTotal / (values.length - 1);
    final optimalPenalty = (average - 58).abs() * 0.8;
    final penalty =
        (averageDeviation * 2.4) + (averageJump * 2.8) + optimalPenalty;

    return (100 - penalty.round()).clamp(0, 100);
  }

  int _waterStressAvoidedIndex(List<int> values, double temperature) {
    if (values.isEmpty) return 0;

    final stableMoistureReadings = values
        .where((value) => value >= 45 && value <= 72)
        .length;
    final criticalDryReadings = values.where((value) => value < 35).length;
    final stableMoistureRatio = stableMoistureReadings / values.length;
    final stabilityScore = _soilStabilityScore(values);
    final heatPenalty = temperature >= 34
        ? 14
        : temperature >= 29
        ? 7
        : 0;
    final dryPenalty = criticalDryReadings * 5;
    final score =
        (stableMoistureRatio * 56 +
                stabilityScore * 0.44 -
                heatPenalty -
                dryPenalty)
            .round();

    return score.clamp(0, 100);
  }

  _RetentionDiagnostic _retentionDiagnostic(
    AppLocalizations l10n,
    List<int> values, {
    required bool hasEnoughHistory,
  }) {
    if (!hasEnoughHistory) {
      return _RetentionDiagnostic(
        hasEnoughHistory: false,
        status: l10n.t('collectingHistory'),
        shortMessage: l10n.t('retentionWaitingShort'),
        body: l10n.t('retentionWaitingBody'),
        recommendation: l10n.t('retentionWaitingRecommendation'),
        score: 0.38,
        color: AppColors.sage,
      );
    }

    var maxDrop = 0;
    var totalDrop = 0;
    for (var i = 1; i < values.length; i++) {
      final drop = math.max(0, values[i - 1] - values[i]);
      maxDrop = math.max(maxDrop, drop);
      totalDrop += drop;
    }

    final averageDrop = totalDrop / (values.length - 1);
    if (maxDrop >= 16 || averageDrop >= 7) {
      return _RetentionDiagnostic(
        hasEnoughHistory: true,
        status: l10n.t('poor'),
        shortMessage: l10n.t('retentionPoorShort'),
        body: l10n.t('retentionPoorBody'),
        recommendation: l10n.t('retentionPoorRecommendation'),
        score: 0.34,
        color: AppColors.earth,
      );
    }

    if (maxDrop >= 9 || averageDrop >= 4) {
      return _RetentionDiagnostic(
        hasEnoughHistory: true,
        status: l10n.t('regular'),
        shortMessage: l10n.t('retentionRegularShort'),
        body: l10n.t('retentionRegularBody'),
        recommendation: l10n.t('retentionRegularRecommendation'),
        score: 0.66,
        color: AppColors.sun,
      );
    }

    return _RetentionDiagnostic(
      hasEnoughHistory: true,
      status: l10n.t('excellent'),
      shortMessage: l10n.t('retentionExcellentShort'),
      body: l10n.t('retentionExcellentBody'),
      recommendation: l10n.t('retentionExcellentRecommendation'),
      score: 0.92,
      color: AppColors.leaf,
    );
  }

  String _stabilityLabel(AppLocalizations l10n, int score) {
    if (score < 60) return l10n.t('unstable');
    if (score < 78) return l10n.t('needsReview');
    if (score < 92) return l10n.t('stable');
    return l10n.t('excellent');
  }

}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String caption;
  final Color color;
  final bool compact;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (compact) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.64),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.56),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.66),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.displaySmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.62),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsHero extends StatelessWidget {
  final int stabilityScore;
  final String stabilityLabel;
  final int waterStressAvoidedIndex;
  final double temperature;
  final int humidity;
  final bool hasEnoughHistory;

  const _AnalyticsHero({
    required this.stabilityScore,
    required this.stabilityLabel,
    required this.waterStressAvoidedIndex,
    required this.temperature,
    required this.humidity,
    required this.hasEnoughHistory,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.canopyGradient,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusHero),
        boxShadow: [
          BoxShadow(
            color: AppColors.canopyEnd.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 650;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('soilStability').toUpperCase(),
                style: tt.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$stabilityScore%',
                style: tt.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.t('stabilityResult')}: $stabilityLabel',
                style: tt.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          );
          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroChip(
                icon: Icons.history_rounded,
                label: hasEnoughHistory
                    ? l10n.t('enoughHistory')
                    : l10n.t('collectingHistory'),
              ),
              _HeroChip(
                icon: Icons.health_and_safety_outlined,
                label:
                    '${l10n.t('waterStressAvoidedShort')} $waterStressAvoidedIndex%',
              ),
              _HeroChip(
                icon: Icons.thermostat_rounded,
                label: l10n.temperature(temperature),
              ),
              _HeroChip(
                icon: Icons.water_drop_rounded,
                label: '${l10n.t('humidity')} $humidity%',
              ),
            ],
          );
          final ring = _StabilityRing(
            score: stabilityScore,
            label: stabilityLabel,
            foregroundColor: Colors.white,
            trackColor: Colors.white.withValues(alpha: 0.18),
            size: narrow ? 102 : 128,
          );
          final divider = Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            height: 1,
            color: Colors.white.withValues(alpha: 0.14),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ring,
                  SizedBox(width: narrow ? 18 : 24),
                  Expanded(child: copy),
                ],
              ),
              divider,
              chips,
            ],
          );
        },
      ),
    );
  }
}

class _StabilityRing extends StatelessWidget {
  final int score;
  final String label;
  final Color foregroundColor;
  final Color trackColor;
  final double size;

  const _StabilityRing({
    required this.score,
    required this.label,
    required this.foregroundColor,
    required this.trackColor,
    this.size = 112,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final stroke = size * 0.1;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: stroke,
              color: trackColor,
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: stroke,
              strokeCap: StrokeCap.round,
              color: foregroundColor,
              backgroundColor: Colors.transparent,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$score',
                style: tt.headlineMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  fontSize: size * 0.26,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final List<int> values;

  const _TrendCard({required this.values});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final average = values.reduce((a, b) => a + b) / values.length;
    // Cada punto es un riego real (humedad del suelo al iniciarlo), del mas
    // antiguo al mas reciente.
    final labels = List<String>.generate(
      values.length,
      (i) => 'R${i + 1}',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
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
                  color: AppColors.leaf.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.show_chart, color: AppColors.leaf),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('weeklyMoistureTrend'),
                      style: tt.headlineSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.t('weeklyMoistureSubtitle'),
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TrendLegendItem(
                label: '${l10n.t('minimum')}: $min%',
                color: AppColors.earth,
              ),
              _TrendLegendItem(
                label: '${l10n.t('averageHumidity')}: ${average.round()}%',
                color: AppColors.leaf,
              ),
              _TrendLegendItem(
                label: '${l10n.t('maximum')}: $max%',
                color: AppColors.sun,
              ),
              _TrendLegendItem(
                label: l10n.t('healthyRange'),
                color: AppColors.aqua,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(6, 14, 10, 6),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
            ),
            child: SizedBox(
              height: 240,
              child: _MoistureTrendChart(values: values, labels: labels),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.t('trendExplanation'),
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.62),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendLegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _TrendLegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoistureTrendChart extends StatelessWidget {
  final List<int> values;
  final List<String> labels;

  const _MoistureTrendChart({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CustomPaint(
      painter: _MoistureTrendPainter(
        values: values,
        labels: labels,
        lineColor: cs.primary,
        // Banda saludable en aqua: es "zona de agua correcta", no la línea.
        bandColor: AppColors.aqua,
        cardColor: cs.surfaceContainerHighest,
        gridColor: cs.outline.withValues(alpha: 0.32),
        textColor: cs.onSurface.withValues(alpha: 0.6),
        valueColor: cs.onSurface,
      ),
      size: Size.infinite,
    );
  }
}

class _MoistureTrendPainter extends CustomPainter {
  final List<int> values;
  final List<String> labels;
  final Color lineColor;
  final Color bandColor;
  final Color cardColor;
  final Color gridColor;
  final Color textColor;
  final Color valueColor;

  const _MoistureTrendPainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    required this.bandColor,
    required this.cardColor,
    required this.gridColor,
    required this.textColor,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 36.0;
    const right = 16.0;
    const top = 24.0;
    const bottom = 30.0;
    const minY = 20.0;
    const maxY = 90.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    if (chartWidth <= 0 || chartHeight <= 0 || values.isEmpty) return;

    double yFor(num value) {
      final normalized = ((value - minY) / (maxY - minY)).clamp(0.0, 1.0);
      return top + chartHeight - chartHeight * normalized;
    }

    double xFor(int index) {
      if (values.length == 1) return left + chartWidth / 2;
      return left + chartWidth * index / (values.length - 1);
    }

    // Healthy band (45–72%).
    final healthyTop = yFor(72);
    final healthyBottom = yFor(45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, healthyTop, chartWidth, healthyBottom - healthyTop),
        const Radius.circular(12),
      ),
      Paint()..color = bandColor.withValues(alpha: 0.12),
    );
    final bandEdge = Paint()
      ..color = bandColor.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(left, healthyTop),
      Offset(left + chartWidth, healthyTop),
      bandEdge,
    );
    canvas.drawLine(
      Offset(left, healthyBottom),
      Offset(left + chartWidth, healthyBottom),
      bandEdge,
    );

    // Horizontal grid + axis labels.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final yValue in [30, 45, 60, 72, 90]) {
      final y = yFor(yValue);
      canvas.drawLine(Offset(left, y), Offset(left + chartWidth, y), gridPaint);
      _drawText(
        canvas,
        '$yValue',
        Offset(2, y - 7),
        textColor,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      );
    }

    // Build a smooth curve through the points.
    final points = [
      for (var i = 0; i < values.length; i++) Offset(xFor(i), yFor(values[i])),
    ];
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Gradient area fill under the curve.
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, top + chartHeight)
      ..lineTo(points.first.dx, top + chartHeight)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.32),
            lineColor.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(left, top, chartWidth, chartHeight)),
    );

    // The curve itself.
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    // Points + value labels + day labels.
    final dotFill = Paint()..color = lineColor;
    final dotRing = Paint()..color = cardColor;
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(point, 6.5, dotRing);
      canvas.drawCircle(point, 4, dotFill);
      _drawText(
        canvas,
        '${values[i]}',
        Offset(point.dx, point.dy - 20),
        valueColor,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        center: true,
      );
      _drawText(
        canvas,
        labels[i % labels.length],
        Offset(point.dx, size.height - 18),
        textColor,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        center: true,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    bool center = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = center ? offset.dx - painter.width / 2 : offset.dx;
    painter.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant _MoistureTrendPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.cardColor != cardColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.valueColor != valueColor;
  }
}

class _RetentionCard extends StatelessWidget {
  final _RetentionDiagnostic diagnostic;

  const _RetentionCard({required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
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
                  color: diagnostic.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.grass_outlined,
                  color: diagnostic.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('substrateRetention'),
                      style: tt.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.t('advancedDiagnosis'),
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            diagnostic.status,
            style: tt.displaySmall?.copyWith(
              color: diagnostic.color,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: diagnostic.score,
              color: diagnostic.color,
              backgroundColor: diagnostic.color.withValues(alpha: 0.14),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            diagnostic.body,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.72),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: diagnostic.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: diagnostic.color.withValues(alpha: 0.24),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: diagnostic.color,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    diagnostic.recommendation,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
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

/// Placeholder del gráfico de tendencia mientras no hay suficientes riegos
/// con datos reales de humedad.
class _CollectingDataCard extends StatelessWidget {
  const _CollectingDataCard();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.query_stats_rounded,
            size: 44,
            color: cs.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.t('collectingHistory'),
            style: tt.titleSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'La tendencia de humedad se construye con los datos reales de '
            'cada riego. Riega un par de veces y vuelve por aquí.',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.62),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _RetentionDiagnostic {
  final bool hasEnoughHistory;
  final String status;
  final String shortMessage;
  final String body;
  final String recommendation;
  final double score;
  final Color color;

  const _RetentionDiagnostic({
    required this.hasEnoughHistory,
    required this.status,
    required this.shortMessage,
    required this.body,
    required this.recommendation,
    required this.score,
    required this.color,
  });
}
