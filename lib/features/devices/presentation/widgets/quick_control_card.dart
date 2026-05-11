import 'package:flutter/material.dart';

/// Tarjeta de "Control Rápido" con botones Iniciar/Detener riego (Frame Home).
class QuickControlCard extends StatelessWidget {
  final VoidCallback? onStartIrrigation;
  final VoidCallback? onStopIrrigation;

  const QuickControlCard({
    super.key,
    this.onStartIrrigation,
    this.onStopIrrigation,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF44594E),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Control Rápido',
              style: tt.displayMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ControlButton(
                  label: 'Iniciar Riego',
                  onPressed: onStartIrrigation,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ControlButton(
                  label: 'Detener Riego',
                  onPressed: onStopIrrigation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _ControlButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF94BC9A),
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 20),
        elevation: 0,
      ),
      child: Text(label,
          style: tt.displayMedium?.copyWith(
              color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }
}
