import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/bloc/user_segment_context.dart';
import '../../domain/entities/plant_recommendation.dart';
import '../cubit/recommendation_cubit.dart';

/// Recomendación de riego de la planta, calculada por el backend.
///
/// Sustituye al cálculo que hacía la app sobre el clima: el backend combina
/// humedad del suelo, los umbrales de la especie y el pronóstico. Al experto
/// se le muestra además el motivo con los datos concretos.
class PlantRecommendationCard extends StatelessWidget {
  const PlantRecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendationCubit, RecommendationState>(
      builder: (context, state) {
        // Si falla no se muestra nada: la tarjeta de clima ya cubre el caso.
        if (state is! RecommendationLoaded) return const SizedBox.shrink();

        final advice = state.recommendation.irrigation;
        final tt = Theme.of(context).textTheme;
        final cs = Theme.of(context).colorScheme;
        final (icon, color) = _visualsFor(advice.level);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: color.withValues(alpha: 0.32)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            advice.title,
                            style: tt.titleSmall?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (advice.source == AdviceSource.ai)
                          _AiBadge(color: color),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      advice.body,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.78),
                        height: 1.35,
                      ),
                    ),
                    // El experto quiere ver de dónde sale la conclusión.
                    if (context.isExpertUser && advice.reason.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        advice.reason,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  (IconData, Color) _visualsFor(RecommendationLevel level) {
    return switch (level) {
      RecommendationLevel.act => (
        Icons.priority_high_rounded,
        AppColors.earth,
      ),
      RecommendationLevel.watch => (Icons.schedule_rounded, AppColors.sky),
      RecommendationLevel.ok => (
        Icons.check_circle_outline_rounded,
        AppColors.leaf,
      ),
    };
  }
}

/// Marca que el texto lo redactó la IA (la decisión siempre es del backend).
class _AiBadge extends StatelessWidget {
  final Color color;

  const _AiBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            'IA',
            style: tt.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
