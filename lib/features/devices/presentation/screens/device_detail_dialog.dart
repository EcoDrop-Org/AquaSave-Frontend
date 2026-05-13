import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/device.dart';

void showDeviceDetailDialog(BuildContext context, Device device) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _DeviceDetailDialog(device: device),
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
    final plantName = _primaryPlantName(device);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Detalles de la planta',
                style: tt.headlineSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _CloseButton(onPressed: () => Navigator.of(context).pop()),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 174,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _HealthBadge(label: 'Óptimo'),
              const SizedBox(height: 14),
              Text(
                plantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Solanum lycopersicum · ${device.name} · slot 3',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final cards = [
              _MetricTile(
                icon: Icons.water_drop_outlined,
                label: 'Humedad',
                value: '${device.avgHumidityPct}%',
                caption: '35-75% óptimo',
              ),
              _MetricTile(
                icon: Icons.thermostat_outlined,
                label: 'Temperatura',
                value: '${device.temperatureC.toStringAsFixed(0)}°C',
                caption: 'Confort',
              ),
              const _MetricTile(
                icon: Icons.history_rounded,
                label: 'Último riego',
                value: 'Hace 2h',
                caption: '8 min · 1.4 L',
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
        Text(
          'Humedad actual',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        _HumidityRangeBar(value: device.avgHumidityPct),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                'Últimos 7 riegos',
                style: tt.titleSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Text(
              'Ver historial completo →',
              style: tt.bodySmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MiniHistoryTable(),
      ],
    );
  }

  String _primaryPlantName(Device device) {
    if (device.plantCount <= 1) return 'Tomate cherry del balcón';
    return 'Tomate cherry del balcón';
  }
}

class _DetailActions extends StatelessWidget {
  final Device device;

  const _DetailActions({required this.device});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 620;

    final edit = ElevatedButton.icon(
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => _EditPlantDialog(device: device),
      ),
      icon: const Icon(Icons.edit_outlined),
      label: const Text('Editar'),
    );
    final delete = OutlinedButton.icon(
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => const _DeletePlantDialog(),
      ),
      icon: const Icon(Icons.delete_outline_rounded),
      label: const Text('Eliminar'),
    );
    final close = OutlinedButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(AppLocalizations.of(context).t('close')),
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
                Expanded(flex: 2, child: delete),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: close),
              ],
            ),
    );
  }
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
        color: cs.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cs.onSurface),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.74),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
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
              color: cs.onSurface.withValues(alpha: 0.62),
              fontStyle: FontStyle.italic,
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
            minHeight: 8,
            value: clamped,
            color: cs.primary,
            backgroundColor: cs.outline.withValues(alpha: 0.18),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _RangeLabel('0%'),
            _RangeLabel('Min 35'),
            _RangeLabel('Máx 75'),
            _RangeLabel('100%'),
          ],
        ),
      ],
    );
  }
}

class _MiniHistoryTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rows = const [
      ('09 May · 06:30', '8 min', '1.4 L', 'Auto'),
      ('08 May · 19:15', '6 min', '1.0 L', 'Manual'),
      ('08 May · 06:30', '8 min', '1.4 L', 'Auto'),
      ('07 May · 06:30', '10 min', '1.7 L', 'Auto'),
      ('06 May · 18:00', '5 min', '0.9 L', 'Manual'),
      ('06 May · 06:30', '8 min', '1.4 L', 'Auto'),
      ('05 May · 06:30', '8 min', '1.4 L', 'Auto'),
    ];
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
              child: const Row(
                children: [
                  _MiniHeader('Fecha y hora', width: 190),
                  _MiniHeader('Duración', width: 110),
                  _MiniHeader('Litros', width: 100),
                  _MiniHeader('Tipo', width: 120),
                ],
              ),
            ),
            for (final row in rows)
              Container(
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.78),
                  border: Border(
                    top: BorderSide(color: cs.outline.withValues(alpha: 0.26)),
                  ),
                ),
                child: Row(
                  children: [
                    _MiniCell(row.$1, width: 190),
                    _MiniCell(row.$2, width: 110),
                    _MiniCell(row.$3, width: 100),
                    _MiniBadge(row.$4, width: 120),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditPlantDialog extends StatefulWidget {
  final Device device;

  const _EditPlantDialog({required this.device});

  @override
  State<_EditPlantDialog> createState() => _EditPlantDialogState();
}

class _EditPlantDialogState extends State<_EditPlantDialog> {
  late final TextEditingController _nameCtrl;
  double _min = 35;
  double _max = 75;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: 'Tomate cherry del balcón');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
                  Expanded(
                    child: Text(
                      'Editar planta',
                      style: tt.headlineSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _CloseButton(onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.local_florist_rounded,
                      color: cs.primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormLabel('FOTO DETECTADA'),
                        const SizedBox(height: 4),
                        Text(
                          'Solanum lycopersicum · 92% confianza',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.72),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.upload_outlined, size: 16),
                              label: const Text('Reemplazar'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.auto_awesome, size: 16),
                              label: const Text('Re-detectar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _FormLabel('NOMBRE'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.eco_outlined),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 520;
                  final deviceField = _ReadOnlyField(
                    label: 'DISPOSITIVO',
                    value: widget.device.name,
                    icon: Icons.sensors_rounded,
                  );
                  const slotField = _ReadOnlyField(
                    label: 'SLOT',
                    value: '3',
                    icon: Icons.grid_4x4_outlined,
                  );

                  if (compact) {
                    return Column(
                      children: [
                        deviceField,
                        const SizedBox(height: 12),
                        slotField,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: deviceField),
                      const SizedBox(width: 12),
                      SizedBox(width: 150, child: slotField),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              _FormLabel('UMBRALES DE HUMEDAD'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SliderLabel(label: 'Humedad mínima', value: _min),
                    Slider(
                      min: 0,
                      max: 100,
                      value: _min,
                      onChanged: (value) {
                        if (value >= _max) return;
                        setState(() => _min = value);
                      },
                    ),
                    _SliderLabel(label: 'Humedad máxima', value: _max),
                    Slider(
                      min: 0,
                      max: 100,
                      value: _max,
                      onChanged: (value) {
                        if (value <= _min) return;
                        setState(() => _max = value);
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Recomendado para tomates: 40 - 70%.',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.62),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar cambios'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const _DeletePlantDialog(),
                    ),
                    child: const Icon(Icons.delete_outline_rounded),
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

class _DeletePlantDialog extends StatelessWidget {
  const _DeletePlantDialog();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(
        '¿Eliminar planta?',
        style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      content: const Text(
        'La planta se retirará del dispositivo. Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(backgroundColor: cs.error),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}

class _HealthBadge extends StatelessWidget {
  final String label;

  const _HealthBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.56),
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
    final auto = value == 'Auto';
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: auto
                ? cs.primary.withValues(alpha: 0.14)
                : cs.outline.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: auto ? cs.primary : cs.onSurface.withValues(alpha: 0.72),
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

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outline.withValues(alpha: 0.38)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliderLabel extends StatelessWidget {
  final String label;
  final double value;

  const _SliderLabel({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          '${value.round()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
