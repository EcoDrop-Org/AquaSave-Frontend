import 'package:flutter/material.dart';

/// Cactus kawaii: el avatar del asistente.
///
/// Dibujado con CustomPainter en lugar de una imagen para que escale a
/// cualquier tamano sin perder nitidez y no sume peso al bundle.
class KawaiiCactus extends StatelessWidget {
  final double size;

  /// Ojos cerrados y boca pequena mientras el asistente piensa.
  final bool thinking;

  const KawaiiCactus({super.key, this.size = 40, this.thinking = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CactusPainter(
          body: const Color(0xFF4CAF7D),
          bodyDark: const Color(0xFF3B8F65),
          pot: const Color(0xFFD98E63),
          potDark: const Color(0xFFC2794F),
          thinking: thinking,
        ),
      ),
    );
  }
}

class _CactusPainter extends CustomPainter {
  final Color body;
  final Color bodyDark;
  final Color pot;
  final Color potDark;
  final bool thinking;

  _CactusPainter({
    required this.body,
    required this.bodyDark,
    required this.pot,
    required this.potDark,
    required this.thinking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..style = PaintingStyle.fill;

    // Brazos, detras del tronco para que se vean pegados.
    fill.color = bodyDark;
    _arm(canvas, fill, Rect.fromLTWH(w * 0.14, h * 0.34, w * 0.20, h * 0.13));
    _arm(canvas, fill, Rect.fromLTWH(w * 0.66, h * 0.28, w * 0.20, h * 0.13));
    // Tramos verticales de los brazos.
    fill.color = bodyDark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.26, w * 0.13, h * 0.21),
        Radius.circular(w * 0.07),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.73, h * 0.20, w * 0.13, h * 0.21),
        Radius.circular(w * 0.07),
      ),
      fill,
    );

    // Tronco.
    fill.color = body;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.34, h * 0.10, w * 0.32, h * 0.62),
        Radius.circular(w * 0.16),
      ),
      fill,
    );

    // Maceta.
    final potTop = h * 0.68;
    fill.color = pot;
    final potPath = Path()
      ..moveTo(w * 0.26, potTop)
      ..lineTo(w * 0.74, potTop)
      ..lineTo(w * 0.68, h * 0.95)
      ..lineTo(w * 0.32, h * 0.95)
      ..close();
    canvas.drawPath(potPath, fill);

    // Borde de la maceta.
    fill.color = potDark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.23, potTop - h * 0.04, w * 0.54, h * 0.08),
        Radius.circular(w * 0.03),
      ),
      fill,
    );

    // Cara.
    final eyeY = h * 0.34;
    final eyeDx = w * 0.075;
    fill.color = const Color(0xFF24402F);

    if (thinking) {
      // Ojos cerrados: dos lineas curvas.
      final stroke = Paint()
        ..color = const Color(0xFF24402F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.028
        ..strokeCap = StrokeCap.round;
      for (final dx in [-eyeDx, eyeDx]) {
        final path = Path()
          ..moveTo(w * 0.5 + dx - w * 0.035, eyeY)
          ..quadraticBezierTo(
            w * 0.5 + dx,
            eyeY + h * 0.035,
            w * 0.5 + dx + w * 0.035,
            eyeY,
          );
        canvas.drawPath(path, stroke);
      }
    } else {
      for (final dx in [-eyeDx, eyeDx]) {
        canvas.drawCircle(Offset(w * 0.5 + dx, eyeY), w * 0.035, fill);
        // Brillo del ojo.
        fill.color = Colors.white.withValues(alpha: 0.9);
        canvas.drawCircle(
          Offset(w * 0.5 + dx + w * 0.012, eyeY - h * 0.012),
          w * 0.013,
          fill,
        );
        fill.color = const Color(0xFF24402F);
      }
    }

    // Sonrisa.
    final smile = Paint()
      ..color = const Color(0xFF24402F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.026
      ..strokeCap = StrokeCap.round;
    final mouthW = thinking ? w * 0.035 : w * 0.055;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5 - mouthW, h * 0.43)
        ..quadraticBezierTo(w * 0.5, h * 0.48, w * 0.5 + mouthW, h * 0.43),
      smile,
    );

    // Mejillas.
    fill.color = const Color(0xFFFF8FA3).withValues(alpha: 0.55);
    canvas.drawCircle(Offset(w * 0.385, h * 0.405), w * 0.028, fill);
    canvas.drawCircle(Offset(w * 0.615, h * 0.405), w * 0.028, fill);
  }

  void _arm(Canvas canvas, Paint paint, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CactusPainter old) => old.thinking != thinking;
}
