import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/profile_data_card.dart';
import '../widgets/user_avatar.dart';

/// Frame 3 — User Profile. Solo renderiza contenido; el sidebar lo gestiona el router.
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

// ── Main profile content ──────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  final dynamic user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = AppTextStyles.of(context);
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Column(
      children: [
        // Top bar
        Container(
          height: isWide ? 80 : 60,
          padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppConstants.navProfile,
                style: tt.displayMedium?.copyWith(
                  color: const Color(0xFF2D3D2C),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined,
                        color: cs.onSurface, size: isWide ? 28 : 22),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  UserAvatar(
                    name: user.name,
                    avatarUrl: user.avatarUrl,
                    radius: isWide ? 24 : 18,
                    fontSize: 12,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? AppDimensions.spaceLg : AppDimensions.spaceMd),
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cambiar contraseña',
              style: tt.headlineMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: AppDimensions.spaceMd),
          Row(
            children: [
              Expanded(child: _PasswordField(label: 'Contraseña actual')),
              const SizedBox(width: AppDimensions.spaceMd),
              Expanded(child: _PasswordField(label: 'Nueva contraseña')),
            ],
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
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 16, color: cs.onSurface),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: tt.bodySmall
                  ?.copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notificaciones',
              style: tt.headlineMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: AppDimensions.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recibir alertas',
                  style: tt.titleMedium?.copyWith(color: cs.onSurface)),
              Switch(
                value: _enabled,
                activeThumbColor: const Color(0xFF2D3D2C),
                onChanged: (v) => setState(() => _enabled = v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
