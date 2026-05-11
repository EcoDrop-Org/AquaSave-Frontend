import 'package:flutter/material.dart';

/// Campo de texto con estilo subrayado (línea inferior), como en Figma Login/Register.
class AuthUnderlineField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: tt.bodyLarge?.copyWith(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: tt.bodyLarge?.copyWith(color: cs.onSurface),
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.5)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.5)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.only(bottom: 8),
      ),
    );
  }
}
