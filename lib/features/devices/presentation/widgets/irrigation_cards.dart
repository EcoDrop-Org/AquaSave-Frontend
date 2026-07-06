import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/irrigation_cubit.dart';

String _hora(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String _duracion(DateTime start, DateTime end) {
  final seconds = end.difference(start).inSeconds;
  if (seconds < 60) return '$seconds s';
  final minutes = (seconds / 60).round();
  return '$minutes min';
}

String _reloj(int elapsedSeconds) {
  final minutes = elapsedSeconds ~/ 60;
  final seconds = elapsedSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class AutoIrrigationCard extends StatelessWidget {
  final String deviceId;

  const AutoIrrigationCard({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<IrrigationCubit, IrrigationState>(
      builder: (context, state) {
        final running =
            state.isIrrigating &&
            state.deviceId == deviceId &&
            state.triggerType != 'manual';
        final origen = state.triggerType == 'scheduled'
            ? 'Activado por la programación'
            : 'Activado por los sensores';

        return _CardShell(
          icon: Icons.autorenew_rounded,
          title: 'Riego automático',
          active: running,
          child: running
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TimerBig(display: _reloj(state.elapsedSeconds)),
                    const SizedBox(height: 6),
                    Text(
                      '$origen · inició a las '
                      '${state.startedAt != null ? _hora(state.startedAt!) : '—'}',
                      style: tt.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: _StopButton(
                        onPressed: () => context.read<IrrigationCubit>().stop(),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inactivo',
                      style: tt.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Se activa solo cuando la humedad del suelo baja.',
                      style: tt.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _LastRunLine(
                      label: state.lastAutoStart != null &&
                              state.lastAutoEnd != null
                          ? 'Último: inició ${_hora(state.lastAutoStart!)} · '
                                'duró ${_duracion(state.lastAutoStart!, state.lastAutoEnd!)} · '
                                'terminó ${_hora(state.lastAutoEnd!)}'
                          : 'Aún no ha regado automáticamente.',
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class ManualIrrigationCard extends StatelessWidget {
  final String deviceId;

  const ManualIrrigationCard({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<IrrigationCubit, IrrigationState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.errorMessage != previous.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        final anyRunning =
            state.isIrrigating && state.deviceId == deviceId;
        final manualRunning = anyRunning && state.triggerType == 'manual';

        return _CardShell(
          icon: Icons.touch_app_rounded,
          title: 'Riego manual',
          active: manualRunning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (manualRunning) ...[
                _TimerBig(display: _reloj(state.elapsedSeconds)),
                const SizedBox(height: 6),
                Text(
                  'Inició a las '
                  '${state.startedAt != null ? _hora(state.startedAt!) : '—'}',
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: _StopButton(
                    onPressed: () => context.read<IrrigationCubit>().stop(),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: anyRunning
                        ? null
                        : () =>
                              context.read<IrrigationCubit>().start(deviceId),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text('Iniciar riego'),
                    style: _buttonStyle(const Color(0xFFCBE7A3)),
                  ),
                ),
                if (anyRunning) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Hay un riego automático en curso.',
                    style: tt.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 14),
              _LastRunLine(
                label: state.lastManualStart != null &&
                        state.lastManualEnd != null
                    ? 'Último manual: duró '
                          '${_duracion(state.lastManualStart!, state.lastManualEnd!)} · '
                          'se detuvo a las ${_hora(state.lastManualEnd!)}'
                    : 'Aún no has regado manualmente.',
              ),
            ],
          ),
        );
      },
    );
  }
}

ButtonStyle _buttonStyle(Color bg) {
  const fg = Color(0xFF2D3D2C);
  return ElevatedButton.styleFrom(
    backgroundColor: bg,
    disabledBackgroundColor: bg.withValues(alpha: 0.36),
    foregroundColor: fg,
    disabledForegroundColor: fg.withValues(alpha: 0.62),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.symmetric(vertical: 16),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
  );
}

class _StopButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StopButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.stop_rounded, size: 22),
      label: const Text('Detener riego'),
      style: _buttonStyle(Colors.white),
    );
  }
}

class _CardShell extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final Widget child;

  const _CardShell({
    required this.icon,
    required this.title,
    required this.active,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F7A5C), Color(0xFF35513F)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: active
              ? const Color(0xFFCBE7A3)
              : Colors.white.withValues(alpha: 0.12),
          width: active ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: tt.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _Badge(active: active),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final bool active;

  const _Badge({required this.active});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFCBE7A3)
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? 'REGANDO' : 'DETENIDO',
        style: tt.labelSmall?.copyWith(
          color: active ? const Color(0xFF2D3D2C) : Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _TimerBig extends StatelessWidget {
  final String display;

  const _TimerBig({required this.display});

  @override
  Widget build(BuildContext context) {
    return Text(
      display,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    );
  }
}

class _LastRunLine extends StatelessWidget {
  final String label;

  const _LastRunLine({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history_rounded,
            size: 15,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
