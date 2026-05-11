import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/user.dart';
import 'user_avatar.dart';

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
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 720;
          final fields = _ProfileFields(user: user);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.titlePersonalData,
                style: tt.headlineMedium?.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              if (stacked) ...[
                Center(
                  child: UserAvatar(
                    name: user.name,
                    avatarUrl: user.avatarUrl,
                    radius: AppDimensions.avatarSize / 2,
                    showEditBadge: true,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLg),
                fields,
              ] else
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
                    Expanded(child: fields),
                  ],
                ),
              const SizedBox(height: AppDimensions.spaceMd),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3D2C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    AppConstants.btnSaveChanges,
                    style: tt.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileFields extends StatelessWidget {
  final User user;

  const _ProfileFields({required this.user});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 560;
        final fields = [
          _LabeledField(label: 'NOMBRE', value: user.name),
          _LabeledField(label: AppConstants.labelEmail, value: user.email),
          _LabeledField(
            label: AppConstants.labelPhone,
            value: user.phone ?? '',
          ),
          _LabeledField(
            label: AppConstants.labelUserType,
            value: user.userType ?? '',
          ),
        ];

        if (stacked) {
          return Column(
            children: [
              for (final field in fields) ...[
                field,
                const SizedBox(height: AppDimensions.spaceSm),
              ],
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: fields[0]),
                const SizedBox(width: AppDimensions.spaceMd),
                Expanded(child: fields[1]),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceSm),
            Row(
              children: [
                Expanded(child: fields[2]),
                const SizedBox(width: AppDimensions.spaceMd),
                Expanded(child: fields[3]),
              ],
            ),
          ],
        );
      },
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
            color: cs.onSurface.withValues(alpha: 0.78),
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
