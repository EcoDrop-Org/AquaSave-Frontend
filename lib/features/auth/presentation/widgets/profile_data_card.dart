import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/user.dart';
import 'user_avatar.dart';

class ProfileDataCard extends StatefulWidget {
  final User user;

  const ProfileDataCard({super.key, required this.user});

  @override
  State<ProfileDataCard> createState() => _ProfileDataCardState();
}

class _ProfileDataCardState extends State<ProfileDataCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _userTypeCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _userTypeCtrl = TextEditingController(text: widget.user.userType ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _userTypeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 720;
          final fields = _ProfileFields(
            nameCtrl: _nameCtrl,
            emailCtrl: _emailCtrl,
            phoneCtrl: _phoneCtrl,
            userTypeCtrl: _userTypeCtrl,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('personalData'),
                style: tt.headlineMedium?.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              if (stacked) ...[
                Center(
                  child: UserAvatar(
                    name: widget.user.name,
                    avatarUrl: widget.user.avatarUrl,
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
                      name: widget.user.name,
                      avatarUrl: widget.user.avatarUrl,
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.t('profileUpdated'))),
                    );
                  },
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    l10n.t('saveChanges'),
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
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController userTypeCtrl;

  const _ProfileFields({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.userTypeCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 560;
        final fields = [
          _EditableProfileField(
            label: l10n.t('name'),
            controller: nameCtrl,
            icon: Icons.person_outline,
          ),
          _EditableProfileField(
            label: l10n.t('email'),
            controller: emailCtrl,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          _EditableProfileField(
            label: l10n.t('phone'),
            controller: phoneCtrl,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          _EditableProfileField(
            label: l10n.t('userType'),
            controller: userTypeCtrl,
            icon: Icons.badge_outlined,
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

class _EditableProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;

  const _EditableProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
  });

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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 19),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
        ),
      ],
    );
  }
}
