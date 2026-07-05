import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../bloc/irrigation_cubit.dart';

class QuickControlCard extends StatelessWidget {
  final String deviceId;
  final VoidCallback? onStartIrrigation;
  final VoidCallback? onStopIrrigation;

  const QuickControlCard({
    super.key,
    required this.deviceId,
    this.onStartIrrigation,
    this.onStopIrrigation,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<IrrigationCubit, IrrigationState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.errorMessage != previous.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      builder: (context, state) {
        final isIrrigating = state.isIrrigating && state.deviceId == deviceId;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F7A5C), Color(0xFF35513F)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.t('quickControl'),
                          style: tt.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.t('manualActions'),
                          style: tt.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.68),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _IrrigationStatusBadge(isIrrigating: isIrrigating),
                ],
              ),
              const SizedBox(height: 18),
              _IrrigationTimer(
                elapsedSeconds: isIrrigating ? state.elapsedSeconds : 0,
                isIrrigating: isIrrigating,
                triggerType: isIrrigating ? state.triggerType : null,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 520;
                  final startButton = _ControlButton(
                    icon: Icons.play_arrow_rounded,
                    label: l10n.t('startIrrigation'),
                    onPressed: isIrrigating
                        ? null
                        : () async {
                            final started = await context
                                .read<IrrigationCubit>()
                                .start(deviceId);
                            if (started) onStartIrrigation?.call();
                          },
                  );
                  final stopButton = _ControlButton(
                    icon: Icons.stop_rounded,
                    label: l10n.t('stopIrrigation'),
                    onPressed: isIrrigating
                        ? () async {
                            final stopped = await context
                                .read<IrrigationCubit>()
                                .stop();
                            if (stopped) onStopIrrigation?.call();
                          }
                        : null,
                    inverse: true,
                  );

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        startButton,
                        const SizedBox(height: 12),
                        stopButton,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: startButton),
                      const SizedBox(width: 14),
                      Expanded(child: stopButton),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IrrigationStatusBadge extends StatelessWidget {
  final bool isIrrigating;

  const _IrrigationStatusBadge({required this.isIrrigating});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final color = isIrrigating ? const Color(0xFFCBE7A3) : Colors.white;
    final fg = isIrrigating ? const Color(0xFF2D3D2C) : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isIrrigating ? color : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(active: isIrrigating),
          const SizedBox(width: 8),
          Text(
            isIrrigating ? l10n.t('watering') : l10n.t('stopped'),
            style: tt.bodySmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  final bool active;

  const _PulseDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: active ? 11 : 9,
      height: active ? 11 : 9,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2D3D2C) : Colors.white70,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _IrrigationTimer extends StatelessWidget {
  final int elapsedSeconds;
  final bool isIrrigating;

  /// Origen del riego en curso ('manual' | 'automatic' | 'scheduled').
  /// Cuando lo inicio el propio dispositivo o la programacion, se aclara al
  /// usuario que NO fue el quien lo activo.
  final String? triggerType;

  const _IrrigationTimer({
    required this.elapsedSeconds,
    required this.isIrrigating,
    this.triggerType,
  });

  String _originLabel(AppLocalizations l10n) {
    switch (triggerType) {
      case 'automatic':
        return 'Activado automáticamente por los sensores';
      case 'scheduled':
        return 'Activado por la programación automática';
      default:
        return l10n.t('wateringSessionTime');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    final display =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.timer_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  display,
                  style: tt.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isIrrigating ? _originLabel(l10n) : l10n.t('timerWillStart'),
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.68),
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

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool inverse;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.inverse = false,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.inverse ? Colors.white : const Color(0xFFCBE7A3);
    final fg = const Color(0xFF2D3D2C);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        scale: _hovered && widget.onPressed != null ? 1.01 : 1,
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon, size: 22),
          label: Text(widget.label, overflow: TextOverflow.ellipsis),
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            disabledBackgroundColor: bg.withValues(alpha: 0.36),
            foregroundColor: fg,
            disabledForegroundColor: fg.withValues(alpha: 0.62),
            elevation: _hovered && widget.onPressed != null ? 3 : 0,
            shadowColor: Colors.black.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
