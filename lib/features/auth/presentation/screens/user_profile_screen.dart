import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/profile_data_card.dart';
import '../../../subscription/presentation/cubit/plan_cubit.dart';

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
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 640
        ? AppDimensions.spaceMd
        : AppDimensions.spaceLg;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AppHeader(title: l10n.t('navProfile')),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppDimensions.spaceLg,
                horizontalPadding,
                AppDimensions.spaceXl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    children: [
                      ProfileDataCard(user: user),
                      const SizedBox(height: AppDimensions.spaceMd),
                      const _CurrentPlanCard(),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _PasswordCard(),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _NotificationsCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<PlanCubit, String>(
      builder: (context, plan) {
        final isPremium = plan == PlanCubit.premium;
        final title = isPremium ? l10n.t('premiumPlan') : l10n.t('freePlan');
        final body = isPremium
            ? l10n.t('premiumPlanBody')
            : l10n.t('freePlanBody');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF3E5249),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('activePlan'),
                    style: tt.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.66),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: tt.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: tt.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.74),
                    ),
                  ),
                ],
              );
              final badge = Chip(
                label: Text(l10n.t('selectedPlan')),
                avatar: const Icon(Icons.check_circle, size: 18),
                backgroundColor: const Color(0xFFCBE7A3),
                labelStyle: tt.bodySmall?.copyWith(
                  color: const Color(0xFF263B2F),
                  fontWeight: FontWeight.w800,
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, const SizedBox(height: 14), badge],
                );
              }

              return Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: 16),
                  badge,
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _PasswordCard extends StatefulWidget {
  @override
  State<_PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<_PasswordCard> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _newCtrl.addListener(_refreshStrength);
  }

  void _refreshStrength() => setState(() {});

  @override
  void dispose() {
    _newCtrl.removeListener(_refreshStrength);
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _savePassword(AppLocalizations l10n) {
    if (_newCtrl.text.isEmpty || _newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.t('passwordMismatch'))));
      return;
    }

    _currentCtrl.clear();
    _newCtrl.clear();
    _confirmCtrl.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.t('passwordUpdated'))));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final passwordStrength = _passwordStrength(_newCtrl.text);

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.primary.withValues(alpha: 0.14)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.lock_reset_outlined, color: cs.onPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('changePassword'),
                        style: tt.headlineMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        l10n.t('passwordHelp'),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.66),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 640;
              if (stacked) {
                return Column(
                  children: [
                    _PasswordField(
                      label: l10n.t('currentPassword'),
                      controller: _currentCtrl,
                      icon: Icons.key_outlined,
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    _PasswordField(
                      label: l10n.t('newPassword'),
                      controller: _newCtrl,
                      icon: Icons.enhanced_encryption_outlined,
                      helperText: l10n.t('newPasswordHelp'),
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    _PasswordField(
                      label: l10n.t('confirmPassword'),
                      controller: _confirmCtrl,
                      icon: Icons.verified_user_outlined,
                      helperText: l10n.t('confirmPasswordHelp'),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _PasswordField(
                          label: l10n.t('currentPassword'),
                          controller: _currentCtrl,
                          icon: Icons.key_outlined,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMd),
                      Expanded(
                        child: _PasswordField(
                          label: l10n.t('newPassword'),
                          controller: _newCtrl,
                          icon: Icons.enhanced_encryption_outlined,
                          helperText: l10n.t('newPasswordHelp'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceSm),
                  _PasswordField(
                    label: l10n.t('confirmPassword'),
                    controller: _confirmCtrl,
                    icon: Icons.verified_user_outlined,
                    helperText: l10n.t('confirmPasswordHelp'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          _PasswordStrengthMeter(strength: passwordStrength),
          const SizedBox(height: AppDimensions.spaceMd),
          LayoutBuilder(
            builder: (context, constraints) {
              final full = constraints.maxWidth < 520;
              return Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: full ? double.infinity : null,
                  child: ElevatedButton.icon(
                    onPressed: () => _savePassword(l10n),
                    icon: const Icon(Icons.verified_user_outlined),
                    label: Text(l10n.t('savePassword')),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? helperText;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.icon,
    this.helperText,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      style: tt.bodyMedium?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        helperMaxLines: 2,
        prefixIcon: Icon(widget.icon, size: 19),
        suffixIcon: IconButton(
          tooltip: _obscured ? l10n.t('showPassword') : l10n.t('hidePassword'),
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
        filled: true,
        fillColor: cs.surface.withValues(alpha: 0.86),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary, width: 1.6),
        ),
      ),
    );
  }
}

class _PasswordStrengthMeter extends StatelessWidget {
  final int strength;

  const _PasswordStrengthMeter({required this.strength});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final label = switch (strength) {
      0 => l10n.t('passwordStrengthEmpty'),
      1 => l10n.t('passwordStrengthWeak'),
      2 => l10n.t('passwordStrengthMedium'),
      _ => l10n.t('passwordStrengthStrong'),
    };
    final activeColor = switch (strength) {
      1 => const Color(0xFFB7782D),
      2 => const Color(0xFF6B8F3E),
      _ => cs.primary,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield_outlined, size: 18, color: activeColor),
            const SizedBox(width: 8),
            Text(
              '${l10n.t('passwordStrength')}: $label',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.72),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (index) {
            final active = index < strength;
            return Expanded(
              child: Container(
                height: 7,
                margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                decoration: BoxDecoration(
                  color: active
                      ? activeColor
                      : cs.outline.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

int _passwordStrength(String value) {
  if (value.isEmpty) return 0;
  var score = 0;
  if (value.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[a-z]').hasMatch(value)) {
    score++;
  }
  if (RegExp(r'\d').hasMatch(value) ||
      RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
    score++;
  }
  if (score < 1) return 1;
  if (score > 3) return 3;
  return score;
}

// ignore: unused_element
class _OldPasswordField extends StatelessWidget {
  const _OldPasswordField();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ignore: unused_element
class _OldPasswordCardFooter extends StatelessWidget {
  const _OldPasswordCardFooter();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/*
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _savePassword(l10n),
              icon: const Icon(Icons.lock_reset_outlined),
              label: Text(l10n.t('savePassword')),
            ),
          ),
        ],
      ),
    );
  }
}
*/

// ignore: unused_element
class _PasswordFieldLegacy extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const _PasswordFieldLegacy({required this.label, required this.controller});

  @override
  State<_PasswordFieldLegacy> createState() => _PasswordFieldLegacyState();
}

class _PasswordFieldLegacyState extends State<_PasswordFieldLegacy> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      style: tt.bodyMedium?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline, size: 19),
        suffixIcon: IconButton(
          tooltip: _obscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
        filled: true,
        fillColor: cs.surface.withValues(alpha: 0.82),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
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
    final l10n = AppLocalizations.of(context);

    return _SettingsCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final copy = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFE5C73).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFFFE5C73),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('notifications'),
                      style: tt.headlineMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.t('notificationsEnabled'),
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.62),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final control = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _enabled ? l10n.t('enabled') : l10n.t('disabled'),
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _enabled,
                  onChanged: (v) => setState(() => _enabled = v),
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 16), control],
            );
          }

          return Row(
            children: [
              Expanded(child: copy),
              control,
            ],
          );
        },
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}
