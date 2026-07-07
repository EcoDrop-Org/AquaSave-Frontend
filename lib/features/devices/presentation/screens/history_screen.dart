import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../data/datasources/remote/irrigation_remote_datasource.dart';
import '../bloc/devices_bloc.dart';
import '../bloc/irrigation_cubit.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<_IrrigationRecord> _manualEntries = [];

  // En modo real los eventos vienen de GET /api/irrigation/devices/{id}/events.
  final IrrigationRemoteDataSource? _remote =
      AppConstants.useMockData ? null : IrrigationRemoteDataSourceImpl();
  List<_IrrigationRecord> _serverRecords = [];
  String? _fetchedDeviceId;
  bool _wasIrrigating = false;

  Future<void> _fetchServerEvents(String deviceId, String deviceName) async {
    final remote = _remote;
    if (remote == null) return;

    try {
      final events = await remote.getEvents(deviceId);
      events.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      if (!mounted) return;
      setState(() {
        _serverRecords = events
            .map((event) => _recordFromEvent(event, deviceName))
            .toList();
      });
    } catch (_) {
      // Si falla (sin red, backend dormido) se conserva lo que ya habia.
    }
  }

  _IrrigationRecord _recordFromEvent(
    IrrigationEventModel event,
    String deviceName,
  ) {
    final start = event.startedAt.toLocal();
    final end = event.endedAt?.toLocal();
    final elapsed = (end ?? DateTime.now()).difference(start);
    return _IrrigationRecord(
      dateTime: _formatDate(start),
      device: deviceName,
      type: event.triggerType == 'manual'
          ? _IrrigationType.manual
          : _IrrigationType.auto,
      minutes: elapsed.inMinutes < 1 ? 1 : elapsed.inMinutes,
      liters: event.litersConsumed,
      soilMoisture: event.soilMoisturePct?.round(),
      temperatureC: event.temperatureC,
    );
  }

  void _maybeRefetch(DevicesState devicesState, IrrigationState irrigation) {
    if (_remote == null || devicesState is! DevicesLoaded) return;
    if (devicesState.devices.isEmpty) return;

    final device = devicesState.activeDevice;
    final deviceChanged = device.id != _fetchedDeviceId;
    final irrigationToggled = _wasIrrigating != irrigation.isIrrigating;
    if (!deviceChanged && !irrigationToggled) return;

    _fetchedDeviceId = device.id;
    _wasIrrigating = irrigation.isIrrigating;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchServerEvents(device.id, device.name);
    });
  }

  Future<void> _openManualDialog(String activeDeviceName) async {
    final entry = await showDialog<_IrrigationRecord>(
      context: context,
      builder: (_) => _ManualWateringDialog(deviceName: activeDeviceName),
    );
    if (entry == null) return;
    setState(() => _manualEntries.insert(0, entry));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.t('manualSaved'))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final devicesState = context.watch<DevicesBloc>().state;
    final irrigationState = context.watch<IrrigationCubit>().state;
    final activeDevice =
        devicesState is DevicesLoaded && devicesState.devices.isNotEmpty
        ? devicesState.activeDevice
        : null;
    final activeDeviceName = activeDevice?.name ?? 'Mi huerto terraza';
    _maybeRefetch(devicesState, irrigationState);
    final records = [
      ..._manualEntries,
      if (_remote != null)
        ..._serverRecords
      else
        ..._records(
          l10n,
          irrigationState,
          activeDeviceName: activeDeviceName,
          activeDeviceId: activeDevice?.id,
        ),
    ];
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 640
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
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked = constraints.maxWidth < 540;
                          final titleBlock = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.t('wateringHistoryTitle'),
                                style: tt.headlineMedium?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.t('historySubtitle'),
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.68),
                                ),
                              ),
                            ],
                          );
                          final button = ElevatedButton.icon(
                            onPressed: () =>
                                _openManualDialog(activeDeviceName),
                            icon: const Icon(Icons.add_rounded),
                            label: Text(l10n.t('logManualWatering')),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                            ),
                          );
                          if (stacked) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                titleBlock,
                                const SizedBox(height: 14),
                                button,
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: titleBlock),
                              const SizedBox(width: 16),
                              SizedBox(width: 240, child: button),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _HistoryTable(records: records),
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

  List<_IrrigationRecord> _records(
    AppLocalizations l10n,
    IrrigationState irrigationState, {
    required String activeDeviceName,
    required String? activeDeviceId,
  }) {
    final base = <_IrrigationRecord>[
      _IrrigationRecord(
        dateTime: '09 May · 06:30',
        device: activeDeviceName,
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        soilMoisture: 38,
        temperatureC: 24,
      ),
      _IrrigationRecord(
        dateTime: '08 May · 19:15',
        device: activeDeviceName,
        type: _IrrigationType.manual,
        minutes: 6,
        liters: 1.0,
        soilMoisture: 44,
        temperatureC: 24,
      ),
      _IrrigationRecord(
        dateTime: '08 May · 06:30',
        device: activeDeviceName,
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        soilMoisture: 39,
        temperatureC: 24,
      ),
      _IrrigationRecord(
        dateTime: '07 May · 06:30',
        device: activeDeviceName,
        type: _IrrigationType.auto,
        minutes: 10,
        liters: 1.7,
        soilMoisture: 35,
        temperatureC: 24,
      ),
      _IrrigationRecord(
        dateTime: '06 May · 18:00',
        device: activeDeviceName,
        type: _IrrigationType.manual,
        minutes: 5,
        liters: 0.9,
        soilMoisture: 46,
        temperatureC: 24,
      ),
      _IrrigationRecord(
        dateTime: '06 May · 06:30',
        device: activeDeviceName,
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        soilMoisture: 38,
        temperatureC: 24,
      ),
      _IrrigationRecord(
        dateTime: '05 May · 06:30',
        device: activeDeviceName,
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        soilMoisture: 39,
        temperatureC: 24,
      ),
      _IrrigationRecord(
        dateTime: '04 May · 18:20',
        device: activeDeviceName,
        type: _IrrigationType.manual,
        minutes: 4,
        liters: 0.7,
        soilMoisture: 47,
        temperatureC: 24,
      ),
      _IrrigationRecord(
        dateTime: '04 May · 06:30',
        device: activeDeviceName,
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        soilMoisture: 40,
        temperatureC: 24,
      ),
      _IrrigationRecord(
        dateTime: '03 May · 06:30',
        device: activeDeviceName,
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        soilMoisture: 38,
        temperatureC: 24,
      ),
    ];

    if (irrigationState.isIrrigating &&
        irrigationState.deviceId == activeDeviceId) {
      final startedAt = irrigationState.startedAt ?? DateTime.now();
      final elapsedMinutes = (irrigationState.elapsedSeconds / 60).ceil();
      return [
        _IrrigationRecord(
          dateTime: _formatDate(startedAt),
          device: activeDeviceName,
          type: _IrrigationType.manual,
          minutes: elapsedMinutes < 1 ? 1 : elapsedMinutes,
          liters: irrigationState.elapsedSeconds * 0.02,
          soilMoisture: 42,
          temperatureC: 24,
        ),
        ...base,
      ];
    }

    return base;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} · $hour:$minute';
  }
}

class _HistoryTable extends StatelessWidget {
  final List<_IrrigationRecord> records;

  const _HistoryTable({required this.records});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final columns = <(String, double)>[
      (l10n.t('dateTime'), 190),
      (l10n.t('gardenColumn'), 240),
      (l10n.t('typeCol'), 140),
      (l10n.t('durationCol'), 120),
      (l10n.t('litersCol'), 120),
      (l10n.t('humidity'), 170),
      (l10n.t('temperature'), 180),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  border: Border(
                    bottom: BorderSide(
                      color: cs.primary.withValues(alpha: 0.30),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < columns.length; i++)
                      _HeaderCell(
                        label: columns[i].$1,
                        width: columns[i].$2,
                        isLast: i == columns.length - 1,
                      ),
                  ],
                ),
              ),
              for (var i = 0; i < records.length; i++)
                _HistoryRow(
                  record: records[i],
                  shaded: i.isOdd,
                  widths: [for (final column in columns) column.$2],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatefulWidget {
  final _IrrigationRecord record;
  final bool shaded;
  final List<double> widths;

  const _HistoryRow({
    required this.record,
    required this.shaded,
    required this.widths,
  });

  @override
  State<_HistoryRow> createState() => _HistoryRowState();
}

class _HistoryRowState extends State<_HistoryRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: _hovered
              ? cs.primary.withValues(alpha: 0.06)
              : widget.shaded
              ? cs.surfaceContainerHighest.withValues(alpha: 0.45)
              : Colors.transparent,
          border: Border(
            top: BorderSide(color: cs.outline.withValues(alpha: 0.18)),
          ),
        ),
        child: Row(
          children: [
            _BodyCell(
              widget.record.dateTime,
              width: widget.widths[0],
              icon: Icons.event_rounded,
              strong: true,
            ),
            _BodyCell(
              widget.record.device,
              width: widget.widths[1],
              icon: Icons.eco_rounded,
              iconColor: cs.primary,
            ),
            _TypeBadge(type: widget.record.type, width: widget.widths[2]),
            _BodyCell(
              '${widget.record.minutes} min',
              width: widget.widths[3],
              strong: true,
            ),
            _BodyCell(
              '${widget.record.liters.toStringAsFixed(1)} L',
              width: widget.widths[4],
              icon: Icons.water_drop_rounded,
              iconColor: cs.primary,
              strong: true,
            ),
            _MoistureCell(
              value: widget.record.soilMoisture,
              width: widget.widths[5],
            ),
            _MoistureCell(
              value: widget.record.temperatureC?.round(),
              suffix: '°C',
              icon: Icons.thermostat_rounded,
              width: widget.widths[6],
              accent: true,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cellBorder(BuildContext context, {required bool isLast}) {
  if (isLast) return const BoxDecoration();
  return BoxDecoration(
    border: Border(
      right: BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.22),
      ),
    ),
  );
}

class _MoistureCell extends StatelessWidget {
  final int? value;
  final double width;
  final bool accent;
  final bool isLast;
  final String suffix;
  final IconData icon;

  const _MoistureCell({
    required this.value,
    required this.width,
    this.accent = false,
    this.isLast = false,
    this.suffix = '%',
    this.icon = Icons.water_drop_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = accent ? cs.primary : cs.onSurface.withValues(alpha: 0.78);

    return Container(
      width: width,
      alignment: Alignment.center,
      decoration: _cellBorder(context, isLast: isLast),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: color, size: 13),
          ),
          const SizedBox(width: 9),
          Text(
            value == null ? '—' : '$value$suffix',
            style: tt.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final bool isLast;

  const _HeaderCell({
    required this.label,
    required this.width,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = cs.primary.withValues(alpha: 0.24);

    return Container(
      width: width,
      alignment: Alignment.center,
      decoration: isLast
          ? const BoxDecoration()
          : BoxDecoration(
              border: Border(right: BorderSide(color: borderColor)),
            ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(
        label,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String value;
  final double width;
  final bool strong;
  final IconData? icon;
  final Color? iconColor;

  const _BodyCell(
    this.value, {
    required this.width,
    this.strong = false,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Text(
      value,
      maxLines: 1,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: cs.onSurface,
        fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
      ),
    );

    return Container(
      width: width,
      alignment: Alignment.center,
      decoration: _cellBorder(context, isLast: false),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: icon == null
          ? text
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: iconColor ?? cs.onSurface.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 8),
                Flexible(child: text),
              ],
            ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final _IrrigationType type;
  final double width;

  const _TypeBadge({required this.type, required this.width});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isAuto = type == _IrrigationType.auto;
    final fg = isAuto ? cs.primary : cs.onSurface.withValues(alpha: 0.72);

    return Container(
      width: width,
      alignment: Alignment.center,
      decoration: _cellBorder(context, isLast: false),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isAuto
              ? cs.primary.withValues(alpha: 0.14)
              : cs.outline.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: fg.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAuto ? Icons.auto_awesome : Icons.touch_app_outlined,
              size: 13,
              color: fg,
            ),
            const SizedBox(width: 5),
            Text(
              isAuto ? l10n.t('auto') : l10n.t('manual'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _IrrigationType { auto, manual }

class _IrrigationRecord {
  final String dateTime;
  final String device;
  final _IrrigationType type;
  final int minutes;
  final double liters;
  // Snapshot al iniciar el riego. Null en eventos antiguos sin datos.
  final int? soilMoisture;
  final double? temperatureC;

  const _IrrigationRecord({
    required this.dateTime,
    required this.device,
    required this.type,
    required this.minutes,
    required this.liters,
    required this.soilMoisture,
    required this.temperatureC,
  });
}

class _ManualWateringDialog extends StatefulWidget {
  final String deviceName;

  const _ManualWateringDialog({required this.deviceName});

  @override
  State<_ManualWateringDialog> createState() => _ManualWateringDialogState();
}

class _ManualWateringDialogState extends State<_ManualWateringDialog> {
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  final _durationCtrl = TextEditingController(text: '5');
  final _litersCtrl = TextEditingController(text: '1.0');
  String? _durationError;
  String? _litersError;

  @override
  void dispose() {
    _durationCtrl.dispose();
    _litersCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  String _formatDateLabel() {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${_date.day.toString().padLeft(2, '0')} ${months[_date.month - 1]} ${_date.year}';
  }

  String _formatTimeLabel() {
    return '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final duration = int.tryParse(_durationCtrl.text.trim());
    final liters = double.tryParse(_litersCtrl.text.trim().replaceAll(',', '.'));
    setState(() {
      _durationError = (duration == null || duration < 1 || duration > 120)
          ? l10n.t('invalidManualDuration')
          : null;
      _litersError = (liters == null || liters <= 0)
          ? l10n.t('invalidManualLiters')
          : null;
    });
    if (_durationError != null || _litersError != null) return;

    final dateLabel =
        '${_formatDateLabel().substring(0, 6)} · ${_formatTimeLabel()}';
    Navigator.of(context).pop(
      _IrrigationRecord(
        dateTime: dateLabel,
        device: widget.deviceName,
        type: _IrrigationType.manual,
        minutes: duration!,
        liters: liters!,
        soilMoisture: 40,
        temperatureC: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final mq = MediaQuery.sizeOf(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: mq.width < 600 ? 16 : 48,
        vertical: 36,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                      Icons.water_drop_rounded,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.t('manualWateringTitle'),
                      style: tt.headlineSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.t('manualWateringBody'),
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.68),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, c) {
                  final stacked = c.maxWidth < 360;
                  final date = _PickerTile(
                    label: l10n.t('manualDate'),
                    value: _formatDateLabel(),
                    icon: Icons.event_rounded,
                    onTap: _pickDate,
                  );
                  final time = _PickerTile(
                    label: l10n.t('manualTime'),
                    value: _formatTimeLabel(),
                    icon: Icons.schedule_rounded,
                    onTap: _pickTime,
                  );
                  if (stacked) {
                    return Column(
                      children: [
                        date,
                        const SizedBox(height: 10),
                        time,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: date),
                      const SizedBox(width: 10),
                      Expanded(child: time),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.t('manualDurationMin'),
                  prefixIcon: const Icon(Icons.timer_outlined),
                  errorText: _durationError,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _litersCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.t('manualLitersUsed'),
                  prefixIcon: const Icon(Icons.water_drop_outlined),
                  suffixText: 'L',
                  errorText: _litersError,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(l10n.t('save')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.t('cancel')),
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

class _PickerTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(icon, color: cs.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: tt.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.expand_more_rounded,
                color: cs.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
