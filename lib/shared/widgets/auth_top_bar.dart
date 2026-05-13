import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/theme_mode_cubit.dart';
import 'language_selector.dart';

/// Pequeña barra flotante para las pantallas de login / register: permite
/// cambiar idioma y alternar el modo claro/oscuro antes de iniciar sesión.
class AuthTopBar extends StatelessWidget {
  const AuthTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [LanguageSelector(), SizedBox(width: 10), _ThemeToggle()],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<ThemeModeCubit, ThemeMode>(
      builder: (context, mode) {
        final dark = mode == ThemeMode.dark;
        return Tooltip(
          message: dark ? l10n.t('lightMode') : l10n.t('darkMode'),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: context.read<ThemeModeCubit>().toggle,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.32)),
                ),
                child: Icon(
                  dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: cs.onSurface,
                  size: 18,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
