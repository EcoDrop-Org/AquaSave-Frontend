import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../subscription/presentation/cubit/plan_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _minMoisture = 35;
  double _optimalMoisture = 58;
  double _maxMoisture = 82;
  double _temperatureAlert = 28;
  double _rainThreshold = 70;
  final List<_ScheduleSlot> _scheduleSlots = [
    const _ScheduleSlot(timeText: '06:30'),
  ];

  void _addScheduleSlot() {
    setState(() => _scheduleSlots.add(const _ScheduleSlot(timeText: '')));
  }

  void _updateScheduleSlotTime(int index, String value) {
    setState(
      () => _scheduleSlots[index] = _scheduleSlots[index].copyWith(
        timeText: value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 640
        ? AppDimensions.spaceMd
        : AppDimensions.spaceLg;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AppHeader(title: l10n.t('navSettings')),
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
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('settingsTitle'),
                        style: tt.headlineMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.t('settingsSubtitle'),
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.68),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      BlocBuilder<PlanCubit, String>(
                        builder: (context, selectedPlan) {
                          return _PlanSelector(
                            selectedPlan: selectedPlan,
                            onPlanChanged: context.read<PlanCubit>().setPlan,
                          );
                        },
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _SettingsCard(
                        title: l10n.t('moistureThresholds'),
                        icon: Icons.water_drop_outlined,
                        child: Column(
                          children: [
                            _SliderRow(
                              label: l10n.t('minimum'),
                              value: _minMoisture,
                              min: 10,
                              max: 60,
                              suffix: '%',
                              onChanged: (value) =>
                                  setState(() => _minMoisture = value),
                            ),
                            _SliderRow(
                              label: l10n.t('optimal'),
                              value: _optimalMoisture,
                              min: 35,
                              max: 75,
                              suffix: '%',
                              onChanged: (value) =>
                                  setState(() => _optimalMoisture = value),
                            ),
                            _SliderRow(
                              label: l10n.t('maximum'),
                              value: _maxMoisture,
                              min: 65,
                              max: 95,
                              suffix: '%',
                              onChanged: (value) =>
                                  setState(() => _maxMoisture = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 760;
                          final weatherCard = _SettingsCard(
                            title: l10n.t('weatherGarden'),
                            icon: Icons.cloud_outlined,
                            child: Column(
                              children: [
                                _SliderRow(
                                  label: l10n.t('temperatureAlert'),
                                  value: _temperatureAlert,
                                  min: 20,
                                  max: 40,
                                  suffix: '°C',
                                  onChanged: (value) =>
                                      setState(() => _temperatureAlert = value),
                                ),
                                _SliderRow(
                                  label: l10n.t('rainPauseThreshold'),
                                  value: _rainThreshold,
                                  min: 20,
                                  max: 95,
                                  suffix: '%',
                                  onChanged: (value) =>
                                      setState(() => _rainThreshold = value),
                                ),
                              ],
                            ),
                          );
                          final scheduleCard = _SettingsCard(
                            title: l10n.t('automaticSchedule'),
                            icon: Icons.schedule,
                            child: _ScheduleList(
                              slots: _scheduleSlots,
                              onAdd: _addScheduleSlot,
                              onTimeChanged: _updateScheduleSlotTime,
                              onToggle: (index, value) => setState(
                                () => _scheduleSlots[index] =
                                    _scheduleSlots[index].copyWith(
                                      enabled: value,
                                    ),
                              ),
                              onRemove: (index) => setState(
                                () => _scheduleSlots.removeAt(index),
                              ),
                            ),
                          );

                          if (!wide) {
                            return Column(
                              children: [
                                weatherCard,
                                const SizedBox(height: AppDimensions.spaceMd),
                                scheduleCard,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: weatherCard),
                              const SizedBox(width: AppDimensions.spaceMd),
                              Expanded(child: scheduleCard),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppDimensions.spaceLg),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final fullWidth = constraints.maxWidth < 560;
                          return Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: fullWidth ? double.infinity : null,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.t('settingsSaved')),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.save_outlined),
                                label: Text(l10n.t('saveSettings')),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height:
                            MediaQuery.paddingOf(context).bottom +
                            AppDimensions.spaceMd,
                      ),
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
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF497654)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PlanSelector extends StatelessWidget {
  final String selectedPlan;
  final ValueChanged<String> onPlanChanged;

  const _PlanSelector({
    required this.selectedPlan,
    required this.onPlanChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('choosePlan'),
                      style: tt.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.t('activePlan'),
                      style: tt.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 680;
              final free = _PlanOptionCard(
                title: l10n.t('freePlan'),
                body: l10n.t('freePlanBody'),
                features: [l10n.t('weatherGarden'), l10n.t('manualActions')],
                selected: selectedPlan == 'free',
                onTap: () => onPlanChanged('free'),
              );
              final premium = _PlanOptionCard(
                title: l10n.t('premiumPlan'),
                body: l10n.t('premiumPlanBody'),
                features: [l10n.t('planReports'), l10n.t('planDevices')],
                selected: selectedPlan == 'premium',
                onTap: () => onPlanChanged('premium'),
              );

              if (stacked) {
                return Column(
                  children: [free, const SizedBox(height: 12), premium],
                );
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: free),
                    const SizedBox(width: 12),
                    Expanded(child: premium),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlanOptionCard extends StatelessWidget {
  final String title;
  final String body;
  final List<String> features;
  final bool selected;
  final VoidCallback onTap;

  const _PlanOptionCard({
    required this.title,
    required this.body,
    required this.features,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFCBE7A3)
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFFCBE7A3)
                  : Colors.white.withValues(alpha: 0.16),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: tt.titleMedium?.copyWith(
                        color: selected
                            ? const Color(0xFF263B2F)
                            : Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: selected ? 1 : 0,
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF263B2F),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: tt.bodySmall?.copyWith(
                  color: selected
                      ? const Color(0xFF263B2F).withValues(alpha: 0.72)
                      : Colors.white.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final feature in features)
                    _PlanFeature(label: feature, selected: selected),
                  if (selected)
                    _PlanFeature(
                      label: l10n.t('selectedPlan'),
                      selected: selected,
                      strong: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanFeature extends StatelessWidget {
  final String label;
  final bool selected;
  final bool strong;

  const _PlanFeature({
    required this.label,
    required this.selected,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? const Color(0xFF263B2F) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: strong ? 0.50 : 0.28)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: fg,
          fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${value.round()}$suffix',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          activeColor: const Color(0xFF497654),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ignore: unused_element
class _LegacyScheduleRow extends StatelessWidget {
  final String label;
  final String time;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _LegacyScheduleRow({
    required this.label,
    required this.time,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$time · ${enabled ? l10n.t('enabled') : l10n.t('disabled')}',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
        Switch(value: enabled, onChanged: onChanged),
      ],
    );
  }
}

class _ScheduleSlot {
  final String timeText;
  final bool enabled;

  const _ScheduleSlot({required this.timeText, this.enabled = true});

  _ScheduleSlot copyWith({String? timeText, bool? enabled}) {
    return _ScheduleSlot(
      timeText: timeText ?? this.timeText,
      enabled: enabled ?? this.enabled,
    );
  }
}

class _ScheduleList extends StatelessWidget {
  final List<_ScheduleSlot> slots;
  final VoidCallback onAdd;
  final void Function(int index, String value) onTimeChanged;
  final void Function(int index, bool value) onToggle;
  final void Function(int index) onRemove;

  const _ScheduleList({
    required this.slots,
    required this.onAdd,
    required this.onTimeChanged,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('freeScheduleSubtitle'),
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.62),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        if (slots.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.64),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
            ),
            child: Text(
              l10n.t('noSchedules'),
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.62),
              ),
            ),
          )
        else
          ...List.generate(slots.length, (index) {
            final slot = slots[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == slots.length - 1 ? 0 : 10,
              ),
              child: _ScheduleRow(
                slot: slot,
                onTimeChanged: (value) => onTimeChanged(index, value),
                onToggle: (value) => onToggle(index, value),
                onRemove: slots.length == 1 ? null : () => onRemove(index),
              ),
            );
          }),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l10n.t('addSchedule')),
          ),
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatefulWidget {
  final _ScheduleSlot slot;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onRemove;

  const _ScheduleRow({
    required this.slot,
    required this.onTimeChanged,
    required this.onToggle,
    this.onRemove,
  });

  @override
  State<_ScheduleRow> createState() => _ScheduleRowState();
}

class _ScheduleRowState extends State<_ScheduleRow> {
  late final TextEditingController _timeCtrl;

  @override
  void initState() {
    super.initState();
    _timeCtrl = TextEditingController(text: widget.slot.timeText);
  }

  @override
  void didUpdateWidget(covariant _ScheduleRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.slot.timeText != _timeCtrl.text) {
      _timeCtrl.text = widget.slot.timeText;
    }
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final showError =
        _timeCtrl.text.isNotEmpty && !_isValidTime24(_timeCtrl.text.trim());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.slot.enabled
              ? cs.primary.withValues(alpha: 0.22)
              : cs.outline.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final timeField = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('time24Label'),
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.66),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: showError
                        ? Theme.of(context).colorScheme.error
                        : cs.outline.withValues(alpha: 0.18),
                    width: showError ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule_outlined, color: cs.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _timeCtrl,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        style: tt.titleMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: l10n.t('time24Hint'),
                          hintStyle: tt.titleMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.38),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onChanged: (value) {
                          widget.onTimeChanged(value);
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '24h',
                        style: tt.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                showError ? l10n.t('invalidTime24') : l10n.t('time24Helper'),
                style: tt.bodySmall?.copyWith(
                  color: showError
                      ? Theme.of(context).colorScheme.error
                      : cs.onSurface.withValues(alpha: 0.56),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
          final statusPill = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: widget.slot.enabled
                  ? cs.primary.withValues(alpha: 0.12)
                  : cs.outline.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: widget.slot.enabled
                    ? cs.primary.withValues(alpha: 0.18)
                    : cs.outline.withValues(alpha: 0.16),
              ),
            ),
            child: Text(
              widget.slot.enabled ? l10n.t('enabled') : l10n.t('disabled'),
              style: tt.bodySmall?.copyWith(
                color: widget.slot.enabled ? cs.primary : cs.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
          final header = Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.alarm_outlined, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.t('scheduleTimeTitle'),
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              statusPill,
            ],
          );
          final stateControl = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
            ),
            child: Row(
              mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    l10n.t('scheduleState'),
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.68),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Switch(value: widget.slot.enabled, onChanged: widget.onToggle),
              ],
            ),
          );
          final removeButton = IconButton(
            tooltip: l10n.t('removeSchedule'),
            onPressed: widget.onRemove,
            icon: const Icon(Icons.delete_outline),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 14),
                timeField,
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: stateControl),
                    const SizedBox(width: 10),
                    removeButton,
                  ],
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: timeField),
                  const SizedBox(width: 12),
                  SizedBox(width: 190, child: stateControl),
                  const SizedBox(width: 8),
                  removeButton,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

bool _isValidTime24(String value) {
  return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value);
}
