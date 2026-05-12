import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../bloc/devices_bloc.dart';
import '../bloc/irrigation_cubit.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _period = 'week';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devicesState = context.watch<DevicesBloc>().state;
    final irrigationState = context.watch<IrrigationCubit>().state;
    final activeDevice =
        devicesState is DevicesLoaded && devicesState.devices.isNotEmpty
        ? devicesState.activeDevice
        : null;
    final events = _events(
      l10n,
      irrigationState,
      activeDevice?.id,
    ).where((event) => _matchesPeriod(event, _period)).toList();
    final consumed = events.fold<double>(0, (sum, event) => sum + event.liters);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 640
        ? AppDimensions.spaceMd
        : AppDimensions.spaceLg;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AppHeader(title: l10n.t('navHistory')),
          Expanded(
            child: SingleChildScrollView(
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
                        l10n.t('historyTitle'),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.t('historySubtitle'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.68),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      Wrap(
                        spacing: 10,
                        children: [
                          _PeriodChip(
                            label: l10n.t('last7Days'),
                            selected: _period == 'week',
                            onSelected: () => setState(() => _period = 'week'),
                          ),
                          _PeriodChip(
                            label: l10n.t('last30Days'),
                            selected: _period == 'month',
                            onSelected: () => setState(() => _period = 'month'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _HistoryBody(events: events, consumed: consumed),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesPeriod(_IrrigationHistoryEvent event, String period) {
    final now = DateTime.now();
    final difference = now.difference(event.startedAt);
    return switch (period) {
      'week' => difference.inDays < 7,
      _ => difference.inDays < 31,
    };
  }

  List<_IrrigationHistoryEvent> _events(
    AppLocalizations l10n,
    IrrigationState irrigationState,
    String? activeDeviceId,
  ) {
    final now = DateTime.now();
    final events = [
      _IrrigationHistoryEvent(
        startedAt: now.subtract(const Duration(hours: 3)),
        minutes: 7,
        liters: 8.4,
        trigger: l10n.t('pumpCycle'),
        status: l10n.t('completed'),
        icon: Icons.water_drop_outlined,
      ),
      _IrrigationHistoryEvent(
        startedAt: now.subtract(const Duration(days: 1, hours: 2)),
        minutes: 5,
        liters: 6.2,
        trigger: l10n.t('pumpCycle'),
        status: l10n.t('completed'),
        icon: Icons.water_drop_outlined,
      ),
      _IrrigationHistoryEvent(
        startedAt: now.subtract(const Duration(days: 8, hours: 1)),
        minutes: 8,
        liters: 9.7,
        trigger: l10n.t('pumpCycle'),
        status: l10n.t('completed'),
        icon: Icons.water_drop_outlined,
      ),
    ];

    if (irrigationState.isIrrigating &&
        irrigationState.deviceId == activeDeviceId) {
      events.insert(
        0,
        _IrrigationHistoryEvent(
          startedAt: irrigationState.startedAt ?? now,
          minutes: (irrigationState.elapsedSeconds / 60).ceil(),
          liters: irrigationState.elapsedSeconds * 0.02,
          trigger: l10n.t('pumpCycle'),
          status: l10n.t('pumpRunning'),
          icon: Icons.opacity,
        ),
      );
    }

    return events;
  }
}

class _HistoryBody extends StatelessWidget {
  final List<_IrrigationHistoryEvent> events;
  final double consumed;

  const _HistoryBody({required this.events, required this.consumed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final latest = events.isNotEmpty ? events.first : null;
    final summary = _SummaryGrid(
      cards: [
        _SummaryCard(
          label: l10n.t('cycles'),
          value: '${events.length}',
          icon: Icons.history,
        ),
        _SummaryCard(
          label: l10n.t('litersUsed'),
          value: '${consumed.toStringAsFixed(1)} L',
          icon: Icons.water_drop_outlined,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;

        if (!wide) {
          return Column(
            children: [
              _HistoryHeroCard(consumed: consumed, latest: latest),
              const SizedBox(height: AppDimensions.spaceMd),
              summary,
              const SizedBox(height: AppDimensions.spaceMd),
              _TimelinePanel(events: events),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _HistoryHeroCard(consumed: consumed, latest: latest),
                  const SizedBox(height: AppDimensions.spaceMd),
                  summary,
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMd),
            Expanded(flex: 5, child: _TimelinePanel(events: events)),
          ],
        );
      },
    );
  }
}

class _HistoryHeroCard extends StatelessWidget {
  final double consumed;
  final _IrrigationHistoryEvent? latest;

  const _HistoryHeroCard({required this.consumed, required this.latest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF3E5249),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.timeline, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  latest?.status ?? l10n.t('noNotifications'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${consumed.toStringAsFixed(1)} L',
            style: tt.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.t('litersUsed'),
            style: tt.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.70),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _WaterUsageBar(consumed: consumed),
          const SizedBox(height: 12),
          Text(
            l10n.t('waterUsageMeasuredByPump'),
            style: tt.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.70),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterUsageBar extends StatelessWidget {
  final double consumed;

  const _WaterUsageBar({required this.consumed});

  @override
  Widget build(BuildContext context) {
    final value = (consumed / 60).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 12,
        value: value,
        color: const Color(0xFFCBE7A3),
        backgroundColor: Colors.white.withValues(alpha: 0.14),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<_SummaryCard> cards;

  const _SummaryGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;

        if (!wide) {
          return Column(
            children: [
              for (final card in cards) ...[
                card,
                if (card != cards.last) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (final card in cards) ...[
              Expanded(child: card),
              if (card != cards.last) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  final List<_IrrigationHistoryEvent> events;

  const _TimelinePanel({required this.events});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outline.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.waterfall_chart, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.t('cycles'),
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                l10n.t('noNotifications'),
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.62),
                ),
              ),
            )
          else
            ...events.map((event) => _EventTile(event: event)),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFF497654).withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF497654)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  style: tt.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
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

class _EventTile extends StatelessWidget {
  final _IrrigationHistoryEvent event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.22)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          final leading = Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF497654).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(event.icon, color: const Color(0xFF497654)),
          );
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.trigger,
                style: tt.titleSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${event.startedAt.day.toString().padLeft(2, '0')}/${event.startedAt.month.toString().padLeft(2, '0')}  ${event.startedAt.hour.toString().padLeft(2, '0')}:${event.startedAt.minute.toString().padLeft(2, '0')}',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ],
          );
          final metrics = Column(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Text(
                '${event.liters.toStringAsFixed(1)} L',
                style: tt.titleSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${l10n.t('duration')} ${event.minutes} min',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    leading,
                    const SizedBox(width: 12),
                    Expanded(child: title),
                  ],
                ),
                const SizedBox(height: 12),
                metrics,
              ],
            );
          }

          return Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(child: title),
              metrics,
            ],
          );
        },
      ),
    );
  }
}

class _IrrigationHistoryEvent {
  final DateTime startedAt;
  final int minutes;
  final double liters;
  final String trigger;
  final String status;
  final IconData icon;

  const _IrrigationHistoryEvent({
    required this.startedAt,
    required this.minutes,
    required this.liters,
    required this.trigger,
    required this.status,
    required this.icon,
  });
}
