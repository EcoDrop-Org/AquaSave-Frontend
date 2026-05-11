import 'dart:async';

import 'package:flutter/material.dart';

class QuickControlCard extends StatefulWidget {
  final VoidCallback? onStartIrrigation;
  final VoidCallback? onStopIrrigation;

  const QuickControlCard({
    super.key,
    this.onStartIrrigation,
    this.onStopIrrigation,
  });

  @override
  State<QuickControlCard> createState() => _QuickControlCardState();
}

class _QuickControlCardState extends State<QuickControlCard> {
  bool _isIrrigating = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startIrrigation() {
    if (_isIrrigating) return;

    widget.onStartIrrigation?.call();
    setState(() {
      _isIrrigating = true;
      _elapsedSeconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  void _stopIrrigation() {
    if (!_isIrrigating) return;

    widget.onStopIrrigation?.call();
    _timer?.cancel();
    setState(() => _isIrrigating = false);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF44594E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 22,
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
                      'Control rapido',
                      style: tt.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Acciones manuales para el ciclo de riego.',
                      style: tt.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
              _IrrigationStatusBadge(isIrrigating: _isIrrigating),
            ],
          ),
          const SizedBox(height: 18),
          _IrrigationTimer(
            elapsedSeconds: _elapsedSeconds,
            isIrrigating: _isIrrigating,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 520;
              final startButton = _ControlButton(
                icon: Icons.play_arrow_rounded,
                label: 'Iniciar riego',
                onPressed: _isIrrigating ? null : _startIrrigation,
              );
              final stopButton = _ControlButton(
                icon: Icons.stop_rounded,
                label: 'Detener riego',
                onPressed: _isIrrigating ? _stopIrrigation : null,
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
  }
}

class _IrrigationStatusBadge extends StatelessWidget {
  final bool isIrrigating;

  const _IrrigationStatusBadge({required this.isIrrigating});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = isIrrigating ? const Color(0xFF94BC9A) : Colors.white;
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
            isIrrigating ? 'Regando' : 'Detenido',
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.72, end: active ? 1 : 0.72),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 9 + (active ? value * 2 : 0),
          height: 9 + (active ? value * 2 : 0),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2D3D2C) : Colors.white70,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _IrrigationTimer extends StatelessWidget {
  final int elapsedSeconds;
  final bool isIrrigating;

  const _IrrigationTimer({
    required this.elapsedSeconds,
    required this.isIrrigating,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
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
                  isIrrigating
                      ? 'Tiempo regando en esta sesion'
                      : 'El contador iniciara al activar el riego',
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
    final bg = widget.inverse ? Colors.white : const Color(0xFF94BC9A);
    final fg = widget.inverse ? const Color(0xFF2D3D2C) : Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        scale: _hovered && widget.onPressed != null ? 1.015 : 1,
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon, size: 22),
          label: Text(widget.label),
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
