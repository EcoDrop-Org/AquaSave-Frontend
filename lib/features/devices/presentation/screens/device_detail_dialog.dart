import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/navigation/nav_cubit.dart';
import '../../data/datasources/remote/irrigation_remote_datasource.dart';
import '../../domain/entities/device.dart';
import '../bloc/devices_bloc.dart';

void showDeviceDetailDialog(BuildContext context, Device device) {
  final devicesBloc = context.read<DevicesBloc>();
  final navCubit = context.read<NavCubit>();
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: devicesBloc),
        BlocProvider.value(value: navCubit),
      ],
      child: _DeviceDetailDialog(device: device),
    ),
  );
}

class _DeviceDetailDialog extends StatelessWidget {
  final Device device;

  const _DeviceDetailDialog({required this.device});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final compact = mq.width < 720;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 40,
        vertical: compact ? 18 : 36,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 760, maxHeight: mq.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  compact ? 20 : 32,
                  compact ? 20 : 28,
                  compact ? 20 : 32,
                  0,
                ),
                child: _DetailBody(device: device),
              ),
            ),
            _DetailActions(device: device),
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Device device;

  const _DetailBody({required this.device});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final description = device.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.t('gardenDetails'),
                style: tt.headlineSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _CloseButton(onPressed: () => Navigator.of(context).pop()),
          ],
        ),
        const SizedBox(height: 14),
        // Hero card — just the garden name + optional description.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F7A5C), Color(0xFF35513F)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (device.location.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  device.localizedLocation(
                                    l10n.locale.languageCode,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tt.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.82),
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
              const SizedBox(height: 14),
              Text(
                hasDescription ? description : l10n.t('noDescription'),
                style: tt.bodyMedium?.copyWith(
                  color: hasDescription
                      ? Colors.white.withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.55),
                  fontStyle: hasDescription
                      ? FontStyle.normal
                      : FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final cards = [
              _MetricTile(
                icon: Icons.water_drop_rounded,
                label: l10n.t('humidity'),
                value: '${device.avgHumidityPct}%',
                caption: l10n.t('optimalRange'),
              ),
              _MetricTile(
                icon: Icons.thermostat_rounded,
                label: 'Temp.',
                value: '${device.temperatureC.toStringAsFixed(0)}°C',
                caption: l10n.t('comfortRange'),
              ),
              _MetricTile(
                icon: Icons.eco_rounded,
                label: l10n.t('plantsLabel'),
                value: '${device.plantCount}',
                caption: device.status == DeviceStatus.online
                    ? l10n.t('online')
                    : l10n.t('offline'),
              ),
            ];

            if (compact) {
              return Column(
                children: [
                  for (final card in cards) ...[
                    card,
                    if (card != cards.last) const SizedBox(height: 10),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (final card in cards) ...[
                  Expanded(child: card),
                  if (card != cards.last) const SizedBox(width: 10),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        // ID del dispositivo: se copia en el firmware del ESP32 (DEVICE_ID)
        // para vincular el hardware con este huerto.
        _DeviceIdCard(deviceId: device.id),
        const SizedBox(height: 18),
        Text(
          l10n.t('currentMoisture'),
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        _HumidityRangeBar(value: device.avgHumidityPct),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.t('last7Waterings'),
                style: tt.titleSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Builder(
              builder: (context) => InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  context.read<NavCubit>().goTo(AppTab.history);
                  Navigator.of(context).maybePop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Text(
                    l10n.t('viewFullHistory'),
                    style: tt.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MiniHistoryTable(deviceId: device.id, deviceName: device.name),
      ],
    );
  }
}

class _DeviceIdCard extends StatelessWidget {
  final String deviceId;

  const _DeviceIdCard({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.memory_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.t('deviceIdLabel'),
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.t('deviceIdLabel'),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: deviceId));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.t('deviceIdCopied'))),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(
            deviceId,
            style: tt.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: cs.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.t('deviceIdHint'),
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  final Device device;

  const _DetailActions({required this.device});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 620;
    final l10n = AppLocalizations.of(context);

    final edit = ElevatedButton.icon(
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => _EditGardenDialog(device: device),
      ),
      icon: const Icon(Icons.edit_outlined),
      label: Text(l10n.t('editGarden')),
    );
    final delete = OutlinedButton.icon(
      onPressed: () => _confirmDelete(context, device),
      icon: const Icon(Icons.delete_outline_rounded),
      label: Text(l10n.t('delete')),
    );
    final close = OutlinedButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(l10n.t('close')),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 18, 32, 28),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                edit,
                const SizedBox(height: 10),
                delete,
                const SizedBox(height: 10),
                close,
              ],
            )
          : Row(
              children: [
                Expanded(flex: 5, child: edit),
                const SizedBox(width: 10),
                Expanded(flex: 3, child: delete),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: close),
              ],
            ),
    );
  }
}

Future<void> _confirmDelete(BuildContext context, Device device) async {
  final pageContext = context;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext);
      final tt = Theme.of(dialogContext).textTheme;
      final cs = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        title: Text(
          l10n.t('deleteGardenTitle'),
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        content: Text(l10n.t('deleteGardenBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              pageContext
                  .read<DevicesBloc>()
                  .add(DeleteDeviceRequested(device.id));
              Navigator.of(dialogContext).pop();
              Navigator.of(pageContext).maybePop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: cs.error),
            child: Text(l10n.t('delete')),
          ),
        ],
      );
    },
  );
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String caption;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: cs.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: tt.headlineSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _HumidityRangeBar extends StatelessWidget {
  final int value;

  const _HumidityRangeBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final clamped = (value / 100).clamp(0.0, 1.0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: clamped,
            color: cs.primary,
            backgroundColor: cs.outline.withValues(alpha: 0.18),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _RangeLabel('0%'),
            _RangeLabel('Mín 35'),
            _RangeLabel('Máx 75'),
            _RangeLabel('100%'),
          ],
        ),
      ],
    );
  }
}

class _MiniHistoryTable extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const _MiniHistoryTable({required this.deviceId, required this.deviceName});

  @override
  State<_MiniHistoryTable> createState() => _MiniHistoryTableState();
}

class _MiniHistoryTableState extends State<_MiniHistoryTable> {
  static const _hardcoded = [
    ('09 May · 06:30', '8 min', '1.4 L', 'auto'),
    ('08 May · 19:15', '6 min', '1.0 L', 'manual'),
    ('08 May · 06:30', '8 min', '1.4 L', 'auto'),
    ('07 May · 06:30', '10 min', '1.7 L', 'auto'),
    ('06 May · 18:00', '5 min', '0.9 L', 'manual'),
    ('06 May · 06:30', '8 min', '1.4 L', 'auto'),
    ('05 May · 06:30', '8 min', '1.4 L', 'auto'),
  ];

  final IrrigationRemoteDataSourceImpl? _remote =
      AppConstants.useMockData ? null : IrrigationRemoteDataSourceImpl();

  List<(String, String, String, String)> _rows = _hardcoded;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (!AppConstants.useMockData) _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final events = await _remote!.getEvents(widget.deviceId);
      events.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      final top7 = events.take(7).toList();

      final built = top7.map((e) {
        final day = e.startedAt;
        final dateStr =
            '${day.day.toString().padLeft(2, '0')} '
            '${_monthName(day.month)} · '
            '${day.hour.toString().padLeft(2, '0')}:'
            '${day.minute.toString().padLeft(2, '0')}';
        final durationMin = e.endedAt != null
            ? ((e.endedAt!.difference(e.startedAt).inSeconds) / 60)
                .round()
                .toString()
            : '—';
        final liters = '${e.litersConsumed.toStringAsFixed(1)} L';
        final type = e.triggerType == 'manual' ? 'manual' : 'auto';
        return (dateStr, '$durationMin min', liters, type);
      }).toList();

      if (mounted) setState(() => _rows = built);
    } catch (_) {
      // Sin conexion con la API: mostrar estado vacio en lugar de datos falsos.
      if (mounted) setState(() => _rows = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _monthName(int month) {
    const names = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final rows = _rows;

    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.water_drop_outlined,
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.t('noWateringsYet'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: cs.surfaceContainerHighest,
              child: Row(
                children: [
                  _MiniHeader(l10n.t('dateTime'), width: 190),
                  _MiniHeader(l10n.t('durationCol'), width: 110),
                  _MiniHeader(l10n.t('litersCol'), width: 100),
                  _MiniHeader(l10n.t('typeCol'), width: 120),
                ],
              ),
            ),
            for (var i = 0; i < rows.length; i++)
              Container(
                decoration: BoxDecoration(
                  color: i.isEven
                      ? cs.surface.withValues(alpha: 0.6)
                      : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: Border(
                    top: BorderSide(color: cs.outline.withValues(alpha: 0.22)),
                  ),
                ),
                child: Row(
                  children: [
                    _MiniCell(rows[i].$1, width: 190),
                    _MiniCell(rows[i].$2, width: 110),
                    _MiniCell(rows[i].$3, width: 100),
                    _MiniBadge(rows[i].$4, width: 120),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditGardenDialog extends StatefulWidget {
  final Device device;

  const _EditGardenDialog({required this.device});

  @override
  State<_EditGardenDialog> createState() => _EditGardenDialogState();
}

class _EditGardenDialogState extends State<_EditGardenDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.device.name);
    _descriptionCtrl = TextEditingController(
      text: widget.device.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final desc = _descriptionCtrl.text.trim();
    if (name.length < 3) return;
    context.read<DevicesBloc>().add(
      EditDeviceRequested(
        deviceId: widget.device.id,
        name: name,
        location: widget.device.location,
        plantCount: widget.device.plantCount,
        description: desc.isEmpty ? null : desc,
        clearDescription: desc.isEmpty,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: mq.width < 640 ? 16 : 48,
        vertical: 36,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: mq.height * 0.88),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
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
                    child: Icon(Icons.edit_rounded, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.t('editGarden'),
                      style: tt.headlineSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _CloseButton(onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 22),
              _FormLabel(l10n.t('gardenName').toUpperCase()),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.sensors_rounded),
                  hintText: l10n.t('gardenName'),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _FormLabel(l10n.t('gardenDescription').toUpperCase()),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cs.outline.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.t('optionalLabel'),
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionCtrl,
                minLines: 2,
                maxLines: 4,
                maxLength: 160,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.notes_rounded),
                  hintText: l10n.t('gardenDescriptionHint'),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(l10n.t('saveChanges')),
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

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: AppLocalizations.of(context).t('close'),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: cs.surface,
        side: BorderSide(color: cs.outline.withValues(alpha: 0.32)),
      ),
      icon: const Icon(Icons.close_rounded),
    );
  }
}

class _RangeLabel extends StatelessWidget {
  final String label;

  const _RangeLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
    );
  }
}

class _MiniHeader extends StatelessWidget {
  final String label;
  final double width;

  const _MiniHeader(this.label, {required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _MiniCell extends StatelessWidget {
  final String value;
  final double width;

  const _MiniCell(this.value, {required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String value;
  final double width;

  const _MiniBadge(this.value, {required this.width});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isAuto = value == 'auto';
    final label = isAuto ? l10n.t('auto') : l10n.t('manual');
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isAuto
                ? cs.primary.withValues(alpha: 0.14)
                : cs.outline.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
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

class _FormLabel extends StatelessWidget {
  final String label;

  const _FormLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
  }
}
