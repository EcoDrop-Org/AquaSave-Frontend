import 'package:flutter/material.dart';

class AuthUnderlineField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;

  const AuthUnderlineField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<AuthUnderlineField> createState() => _AuthUnderlineFieldState();
}

class _AuthUnderlineFieldState extends State<AuthUnderlineField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      style: tt.bodyLarge?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: tt.bodyMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.72),
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(
          _iconForLabel(widget.label),
          color: cs.primary,
          size: 20,
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _obscured
                    ? 'Mostrar contraseña'
                    : 'Ocultar contraseña',
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: cs.onSurface.withValues(alpha: 0.64),
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.24)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }

  IconData _iconForLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('pass') || lower.contains('contra')) {
      return Icons.lock_outline;
    }
    if (lower.contains('email')) return Icons.email_outlined;
    return Icons.person_outline;
  }
}
