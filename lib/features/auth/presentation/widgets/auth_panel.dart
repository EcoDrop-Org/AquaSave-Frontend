import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Lado visual de las pantallas de autenticación: la foto botánica con un
/// degradado verde profundo y la marca AquaSave sobre ella.
class AuthHeroPanel extends StatelessWidget {
  /// En pantallas angostas la imagen es una franja superior más baja, con
  /// scrim más ligero y tipografía menor.
  final bool compact;

  const AuthHeroPanel({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(AppConstants.imgLoginPlant, fit: BoxFit.cover),
        // Scrim: garantiza contraste del logo y el tagline sobre la foto.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.canopyEnd.withValues(alpha: 0.12),
                AppColors.canopyEnd.withValues(alpha: compact ? 0.62 : 0.78),
              ],
            ),
          ),
        ),
        Positioned(
          left: compact ? 24 : 48,
          right: compact ? 24 : 48,
          bottom: compact ? 22 : 48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppConstants.imgAquaSaveLogoWhite,
                height: compact ? 42 : 58,
              ),
              SizedBox(height: compact ? 10 : 18),
              Text(
                l10n.t('authTagline'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: (compact ? tt.titleMedium : tt.headlineMedium)?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
