import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../data/datasources/remote/irrigation_remote_datasource.dart';
import '../bloc/devices_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<_ScheduleSlot> _scheduleSlots = [const _ScheduleSlot(timeText: '06:30')];

  final IrrigationRemoteDataSourceImpl? _remote = AppConstants.useMockData
      ? null
      : IrrigationRemoteDataSourceImpl();

  bool _savingSettings = false;
  String? _loadedDeviceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettings());
  }

  String? _activeDeviceId() {
    final state = context.read<DevicesBloc>().state;
    if (state is DevicesLoaded && state.devices.isNotEmpty) {
      return state.activeDevice.id;
    }
    return null;
  }

  Future<void> _loadSettings() async {
    if (_remote == null) return;
    final deviceId = _activeDeviceId();
    if (deviceId == null) return;
    _loadedDeviceId = deviceId;
    try {
      final settings = await _remote.getDeviceSettings(deviceId);
      if (!mounted) return;
      final slots = settings['schedules'];
      if (slots is List && slots.isNotEmpty) {
        setState(() {
          _scheduleSlots = slots
              .whereType<Map<String, dynamic>>()
              .map(
                (s) => _ScheduleSlot(
                  timeText: (s['timeText'] ?? s['time'])?.toString() ?? '06:30',
                  enabled: s['enabled'] as bool? ?? true,
                ),
              )
              .toList();
        });
      }
    } catch (_) {
      // fallback: keeps defaults
    }
  }

  Future<void> _saveSettings(BuildContext ctx) async {
    if (_remote == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(ctx).t('settingsSaved'))),
      );
      return;
    }
    final deviceId = _loadedDeviceId ?? _activeDeviceId();
    if (deviceId == null) return;

    final messenger = ScaffoldMessenger.of(ctx);
    final l10n = AppLocalizations.of(ctx);

    setState(() => _savingSettings = true);
    try {
      // Solo se persisten los horarios: los umbrales de riego viven en el
      // firmware del dispositivo y ya no se configuran desde la app.
      final payload = <String, dynamic>{
        'schedules': _scheduleSlots
            .map((s) => {'timeText': s.timeText, 'enabled': s.enabled})
            .toList(),
      };
      await _remote.putDeviceSettings(deviceId, payload);
      messenger.showSnackBar(SnackBar(content: Text(l10n.t('settingsSaved'))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _savingSettings = false);
    }
  }

  void _addScheduleSlot() {
    setState(() => _scheduleSlots.add(const _ScheduleSlot(timeText: '18:00')));
  }

  void _removeScheduleSlot(int index) {
    setState(() => _scheduleSlots.removeAt(index));
  }

  void _setScheduleSlotTime(int index, String timeText) {
    setState(() {
      final valid = _isValidTime24(timeText);
      _scheduleSlots[index] = _scheduleSlots[index].copyWith(
        timeText: timeText,
        enabled: valid ? _scheduleSlots[index].enabled : false,
      );
    });
  }

  void _setScheduleSlotEnabled(int index, bool enabled) {
    setState(
      () => _scheduleSlots[index] = _scheduleSlots[index].copyWith(
        enabled: enabled,
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
                      // Preferencias de la app (notificaciones, antes en
                      // Perfil) + programacion automatica del riego.
                      // (Los umbrales de humedad y el clima del huerto se
                      // retiraron: el dispositivo riega con sus umbrales y el
                      // clima solo se usa para recomendaciones.)
                      _SettingsCard(
                        title: l10n.t('notifications'),
                        icon: Icons.notifications_active_outlined,
                        child: const _NotificationsToggle(),
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _SettingsCard(
                        title: l10n.t('automaticSchedule'),
                        icon: Icons.schedule,
                        child: _ScheduleList(
                          slots: _scheduleSlots,
                          onAdd: _addScheduleSlot,
                          onTimeChanged: _setScheduleSlotTime,
                          onToggle: _setScheduleSlotEnabled,
                          onRemove: _removeScheduleSlot,
                        ),
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
                                onPressed: _savingSettings
                                    ? null
                                    : () => _saveSettings(context),
                                icon: _savingSettings
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save_outlined),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
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
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 12),
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

/// Interruptor de notificaciones de la app (antes en Perfil). Usa la misma
/// clave de SharedPreferences que lee el centro de notificaciones.
class _NotificationsToggle extends StatefulWidget {
  const _NotificationsToggle();

  @override
  State<_NotificationsToggle> createState() => _NotificationsToggleState();
}

class _NotificationsToggleState extends State<_NotificationsToggle> {
  static const _prefKey = 'notifications_enabled';
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _enabled = prefs.getBool(_prefKey) ?? true);
  }

  Future<void> _toggle(bool value) async {
    setState(() => _enabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.t('notificationsEnabled'),
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.62),
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _enabled ? l10n.t('enabled') : l10n.t('disabled'),
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Switch(value: _enabled, onChanged: _toggle),
            ],
          ),
        ),
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
  final void Function(int index, String timeText) onTimeChanged;
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
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        if (slots.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.alarm_add_rounded,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.t('noSchedules'),
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.62),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(slots.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == slots.length - 1 ? 0 : 12,
              ),
              child: _ScheduleRow(
                index: index,
                slot: slots[index],
                onTimeChanged: (time) => onTimeChanged(index, time),
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
            icon: const Icon(Icons.add_alarm_rounded),
            label: Text(l10n.t('addSchedule')),
          ),
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatefulWidget {
  final int index;
  final _ScheduleSlot slot;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onRemove;

  const _ScheduleRow({
    required this.index,
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
      _timeCtrl.selection = TextSelection.collapsed(
        offset: _timeCtrl.text.length,
      );
    }
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    super.dispose();
  }

  ({IconData icon, String key}) _dayPart(int hour) {
    if (hour < 12) return (icon: Icons.wb_twilight_rounded, key: 'morningTag');
    if (hour < 19) return (icon: Icons.wb_sunny_rounded, key: 'afternoonTag');
    return (icon: Icons.nightlight_round, key: 'nightTag');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final raw = _timeCtrl.text.trim();
    final valid = _isValidTime24(raw);
    final showError = raw.isNotEmpty && !valid;
    final hour = valid ? int.parse(raw.split(':').first) : 6;
    final part = _dayPart(hour);
    final enabled = widget.slot.enabled && valid;
    final accent = showError ? cs.error : cs.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: showError
              ? cs.error
              : enabled
              ? cs.primary.withValues(alpha: 0.30)
              : cs.outline.withValues(alpha: 0.18),
          width: (showError || enabled) ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.t('scheduleTimeTitle')} ${widget.index + 1}',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (valid)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(part.icon, size: 13, color: cs.primary),
                      const SizedBox(width: 5),
                      Text(
                        l10n.t(part.key),
                        style: tt.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.onRemove != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: l10n.t('removeSchedule'),
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Custom digits-only time field — no native clock / time picker.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accent.withValues(alpha: showError ? 0.6 : 0.24),
                width: showError ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: accent, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _timeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_TimeDigitsInputFormatter()],
                    cursorColor: cs.primary,
                    style: tt.headlineMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'HH:MM',
                      hintStyle: tt.headlineMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.26),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                    onChanged: (value) {
                      widget.onTimeChanged(value);
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.16),
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
            showError
                ? l10n.t('invalidTime24')
                : raw.isEmpty
                ? l10n.t('scheduleRequiresTime')
                : l10n.t('time24Helper'),
            style: tt.bodySmall?.copyWith(
              color: (showError || raw.isEmpty)
                  ? cs.error
                  : cs.onSurface.withValues(alpha: 0.56),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                enabled
                    ? Icons.check_circle_rounded
                    : Icons.pause_circle_outline_rounded,
                size: 18,
                color: enabled
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  !valid
                      ? l10n.t('scheduleRequiresTime')
                      : enabled
                      ? l10n.t('scheduleEnabledHint')
                      : l10n.t('scheduleDisabledHint'),
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.66),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(value: enabled, onChanged: valid ? widget.onToggle : null),
            ],
          ),
        ],
      ),
    );
  }
}

bool _isValidTime24(String value) {
  return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value);
}

/// Keeps only digits, caps the length, auto-pads the hours digit and inserts
/// the `:` so the field always reads `HH:MM`. No native clock / time picker.
class _TimeDigitsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 1 && (int.tryParse(digits) ?? 0) > 2) {
      digits = '0$digits';
    }
    if (digits.length > 4) digits = digits.substring(0, 4);
    final out = digits.length <= 2
        ? digits
        : '${digits.substring(0, 2)}:${digits.substring(2)}';
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}
