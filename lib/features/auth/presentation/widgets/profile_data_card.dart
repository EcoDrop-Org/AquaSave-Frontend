import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimensions.dart';
import 'user_avatar.dart';

/// Tarjeta de "Datos personales" del Frame 3 (User Profile).
class ProfileDataCard extends StatelessWidget {
  final User user;

  const ProfileDataCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.titlePersonalData,
            style: tt.headlineMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                name: user.name,
                avatarUrl: user.avatarUrl,
                radius: AppDimensions.avatarSize / 2,
                showEditBadge: true,
              ),
              const SizedBox(width: AppDimensions.spaceLg),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'NOMBRE',
                            value: user.name,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceMd),
                        Expanded(
                          child: _LabeledField(
                            label: AppConstants.labelEmail,
                            value: user.email,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: AppConstants.labelPhone,
                            value: user.phone ?? '',
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceMd),
                        Expanded(
                          child: _LabeledField(
                            label: AppConstants.labelUserType,
                            value: user.userType ?? '',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3D2C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 15),
              ),
              onPressed: () {},
              child: Text(
                AppConstants.btnSaveChanges,
                style: tt.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String value;

  const _LabeledField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.labelLarge?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Text(value, style: tt.bodyMedium),
        ),
      ],
    );
  }
}

