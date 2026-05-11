import 'package:flutter/material.dart';

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
      style: tt.bodyLarge?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: tt.bodyMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.72),
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(_iconForLabel(label), color: cs.primary, size: 20),
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
