import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Fila de texto "¿No tienes cuenta? Regístrate" (o variante).
class AuthLinkRow extends StatelessWidget {
  final String prefixText;
  final String linkText;
  final VoidCallback onTap;

  const AuthLinkRow({
    super.key,
    required this.prefixText,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Text.rich(
        TextSpan(
          text: prefixText,
          style: tt.bodySmall?.copyWith(color: cs.onSurface),
          children: [
            TextSpan(
              text: linkText,
              style: tt.bodySmall?.copyWith(color: AppColors.linkColor),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
