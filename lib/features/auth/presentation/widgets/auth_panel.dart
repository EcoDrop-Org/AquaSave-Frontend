import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Lado visual de las pantallas de autenticación: la foto botánica tal cual,
/// sin degradado ni textos encima.
class AuthHeroPanel extends StatelessWidget {
  /// Se mantiene por compatibilidad con los layouts angostos (franja superior).
  final bool compact;

  const AuthHeroPanel({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppConstants.imgLoginPlant, fit: BoxFit.cover);
  }
}

/// Tarjeta flotante que envuelve los formularios de login y registro.
class AuthFormCard extends StatelessWidget {
  final Widget child;

  const AuthFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 30),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusHero + 4),
        border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.10),
            blurRadius: 42,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Encabezado del formulario: título fuerte + subtítulo suave.
class AuthFormHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthFormHeading({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: tt.displayMedium?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.66),
          ),
        ),
      ],
    );
  }
}
