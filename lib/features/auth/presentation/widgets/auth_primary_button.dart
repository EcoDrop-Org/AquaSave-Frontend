import 'package:flutter/material.dart';

class AuthPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.01 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: SizedBox(
          width: double.infinity,
          height: 57,
          child: ElevatedButton.icon(
            onPressed: widget.isLoading ? null : widget.onPressed,
            icon: widget.isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.arrow_forward_rounded, size: 20),
            label: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    widget.label,
                    style: tt.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              elevation: _hovered ? 4 : 1,
              shadowColor: Colors.black.withValues(alpha: 0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
