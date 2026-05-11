import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/profile_data_card.dart';
import '../widgets/user_avatar.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }
        return _ProfileContent(user: state.user);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final dynamic user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            height: 88,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(color: cs.outline.withValues(alpha: 0.32)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppConstants.navProfile,
                  style: tt.headlineMedium?.copyWith(
                    color: const Color(0xFF2D3D2C),
                  ),
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Notificaciones',
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: cs.onSurface,
                        size: 24,
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 12),
                    UserAvatar(
                      name: user.name,
                      avatarUrl: user.avatarUrl,
                      radius: 22,
                      fontSize: 13,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLg,
                AppDimensions.spaceLg,
                AppDimensions.spaceLg,
                AppDimensions.spaceXl,
              ),
              child: Column(
                children: [
                  ProfileDataCard(user: user),
                  const SizedBox(height: AppDimensions.spaceMd),
                  _PasswordCard(),
                  const SizedBox(height: AppDimensions.spaceMd),
                  _NotificationsCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cambiar contrasena',
            style: tt.headlineMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 640;
              if (stacked) {
                return const Column(
                  children: [
                    _PasswordField(label: 'Contrasena actual'),
                    SizedBox(height: AppDimensions.spaceSm),
                    _PasswordField(label: 'Nueva contrasena'),
                  ],
                );
              }
              return const Row(
                children: [
                  Expanded(child: _PasswordField(label: 'Contrasena actual')),
                  SizedBox(width: AppDimensions.spaceMd),
                  Expanded(child: _PasswordField(label: 'Nueva contrasena')),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;

  const _PasswordField({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 16, color: cs.onSurface),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.62),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsCard extends StatefulWidget {
  @override
  State<_NotificationsCard> createState() => _NotificationsCardState();
}

class _NotificationsCardState extends State<_NotificationsCard> {
  bool _enabled = true;

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificaciones',
                  style: tt.headlineMedium?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'Alertas de humedad critica y eventos de riego.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            activeThumbColor: const Color(0xFF2D3D2C),
            onChanged: (v) => setState(() => _enabled = v),
          ),
        ],
      ),
    );
  }
}
