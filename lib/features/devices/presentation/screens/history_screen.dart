import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../bloc/devices_bloc.dart';
import '../bloc/irrigation_cubit.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final devicesState = context.watch<DevicesBloc>().state;
    final irrigationState = context.watch<IrrigationCubit>().state;
    final activeDevice =
        devicesState is DevicesLoaded && devicesState.devices.isNotEmpty
        ? devicesState.activeDevice
        : null;
    final records = _records(
      l10n,
      irrigationState,
      activeDeviceName: activeDevice?.name ?? 'Mi huerto terraza',
      activeDeviceId: activeDevice?.id,
    );
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
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historial de riegos',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 18),
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
      const _IrrigationRecord(
        dateTime: '09 May · 06:30',
        device: 'Sector A',
        crop: 'Tomate',
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        humidityBefore: 38,
        humidityAfter: 62,
      ),
      const _IrrigationRecord(
        dateTime: '08 May · 19:15',
        device: 'Sector A',
        crop: 'Tomate',
        type: _IrrigationType.manual,
        minutes: 6,
        liters: 1.0,
        humidityBefore: 44,
        humidityAfter: 61,
      ),
      const _IrrigationRecord(
        dateTime: '08 May · 06:30',
        device: 'Sector A',
        crop: 'Tomate',
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        humidityBefore: 39,
        humidityAfter: 63,
      ),
      const _IrrigationRecord(
        dateTime: '07 May · 06:30',
        device: 'Sector A',
        crop: 'Tomate',
        type: _IrrigationType.auto,
        minutes: 10,
        liters: 1.7,
        humidityBefore: 35,
        humidityAfter: 64,
      ),
      const _IrrigationRecord(
        dateTime: '06 May · 18:00',
        device: 'Sector A',
        crop: 'Tomate',
        type: _IrrigationType.manual,
        minutes: 5,
        liters: 0.9,
        humidityBefore: 46,
        humidityAfter: 60,
      ),
      const _IrrigationRecord(
        dateTime: '06 May · 06:30',
        device: 'Sector A',
        crop: 'Tomate',
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        humidityBefore: 38,
        humidityAfter: 62,
      ),
      const _IrrigationRecord(
        dateTime: '05 May · 06:30',
        device: 'Sector A',
        crop: 'Tomate',
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        humidityBefore: 39,
        humidityAfter: 62,
      ),
      const _IrrigationRecord(
        dateTime: '04 May · 18:20',
        device: 'Sector A',
        crop: 'Albahaca',
        type: _IrrigationType.manual,
        minutes: 4,
        liters: 0.7,
        humidityBefore: 47,
        humidityAfter: 58,
      ),
      const _IrrigationRecord(
        dateTime: '04 May · 06:30',
        device: 'Sector A',
        crop: 'Lechuga',
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        humidityBefore: 40,
        humidityAfter: 63,
      ),
      const _IrrigationRecord(
        dateTime: '03 May · 06:30',
        device: 'Sector A',
        crop: 'Tomate',
        type: _IrrigationType.auto,
        minutes: 8,
        liters: 1.4,
        humidityBefore: 38,
        humidityAfter: 62,
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
          crop: 'Cultivo activo',
          type: _IrrigationType.manual,
          minutes: elapsedMinutes < 1 ? 1 : elapsedMinutes,
          liters: irrigationState.elapsedSeconds * 0.02,
          humidityBefore: 42,
          humidityAfter: 42,
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

  static const _columns = [
    ('Fecha y hora', 150.0),
    ('Dispositivo', 150.0),
    ('Cultivo', 120.0),
    ('Tipo', 96.0),
    ('Duración', 96.0),
    ('Litros', 86.0),
    ('Humedad antes', 140.0),
    ('Humedad después', 154.0),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.82),
                child: Row(
                  children: [
                    for (final column in _columns)
                      _HeaderCell(label: column.$1, width: column.$2),
                  ],
                ),
              ),
              for (var i = 0; i < records.length; i++)
                _HistoryRow(
                  record: records[i],
                  shaded: i.isOdd,
                  widths: [for (final column in _columns) column.$2],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final _IrrigationRecord record;
  final bool shaded;
  final List<double> widths;

  const _HistoryRow({
    required this.record,
    required this.shaded,
    required this.widths,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: shaded
            ? cs.surfaceContainerHighest.withValues(alpha: 0.34)
            : cs.surface.withValues(alpha: 0.72),
        border: Border(
          top: BorderSide(color: cs.outline.withValues(alpha: 0.22)),
        ),
      ),
      child: Row(
        children: [
          _BodyCell(record.dateTime, width: widths[0], strong: true),
          _BodyCell(record.device, width: widths[1]),
          _BodyCell(record.crop, width: widths[2]),
          _TypeBadge(type: record.type, width: widths[3]),
          _BodyCell('${record.minutes} min', width: widths[4], strong: true),
          _BodyCell(
            '${record.liters.toStringAsFixed(1)} L',
            width: widths[5],
            strong: true,
          ),
          _BodyCell('${record.humidityBefore}%', width: widths[6]),
          _BodyCell('${record.humidityAfter}%', width: widths[7]),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;

  const _HeaderCell({required this.label, required this.width});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String value;
  final double width;
  final bool strong;

  const _BodyCell(this.value, {required this.width, this.strong = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurface,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
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
    final isAuto = type == _IrrigationType.auto;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isAuto
                ? cs.primary.withValues(alpha: 0.13)
                : cs.outline.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isAuto ? 'Auto' : 'Manual',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isAuto ? cs.primary : cs.onSurface.withValues(alpha: 0.72),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

enum _IrrigationType { auto, manual }

class _IrrigationRecord {
  final String dateTime;
  final String device;
  final String crop;
  final _IrrigationType type;
  final int minutes;
  final double liters;
  final int humidityBefore;
  final int humidityAfter;

  const _IrrigationRecord({
    required this.dateTime,
    required this.device,
    required this.crop,
    required this.type,
    required this.minutes,
    required this.liters,
    required this.humidityBefore,
    required this.humidityAfter,
  });
}
