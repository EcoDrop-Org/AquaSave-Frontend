import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/navigation/nav_cubit.dart';
import '../../core/theme/theme_mode_cubit.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/widgets/user_avatar.dart';
import 'language_selector.dart';
import 'notification_button.dart';

class AppHeader extends StatelessWidget {
  final String title;

  const AppHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated
        ? authState.user.name.split(' ').first
        : l10n.t('userFallback');
    final avatarUrl = authState is AuthAuthenticated
        ? authState.user.avatarUrl
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;

        return Container(
          height: compact ? 74 : 88,
          padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 32),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.72),
            border: Border(
              bottom: BorderSide(color: cs.outline.withValues(alpha: 0.24)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (compact ? tt.titleLarge : tt.headlineMedium)
                      ?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              SizedBox(width: compact ? 8 : 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LanguageSelector(),
                  const SizedBox(width: 8),
                  const _ThemeModeButton(),
                  const SizedBox(width: 8),
                  const NotificationButton(),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () =>
                          context.read<NavCubit>().goTo(AppTab.profile),
                      child: UserAvatar(
                        name: userName,
                        avatarUrl: avatarUrl,
                        radius: 22,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton();

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
              borderRadius: BorderRadius.circular(14),
              onTap: context.read<ThemeModeCubit>().toggle,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.20)),
                ),
                child: Icon(
                  dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: cs.onSurface,
                  size: 21,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
