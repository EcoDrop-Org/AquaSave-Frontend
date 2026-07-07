import 'package:flutter/material.dart';

/// Fila de texto "¿No tienes cuenta? Regístrate" (o variante).
class AuthLinkRow extends StatefulWidget {
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
  State<AuthLinkRow> createState() => _AuthLinkRowState();
}

class _AuthLinkRowState extends State<AuthLinkRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        // Área táctil cómoda sin alterar la composición.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text.rich(
            TextSpan(
              text: widget.prefixText,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.72),
              ),
              children: [
                TextSpan(
                  text: widget.linkText,
                  style: tt.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                    decoration:
                        _hovered ? TextDecoration.underline : null,
                    decorationColor: cs.primary,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
