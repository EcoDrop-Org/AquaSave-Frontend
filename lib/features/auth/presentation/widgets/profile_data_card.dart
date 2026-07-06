import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
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
  late final TextEditingController _userTypeCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _userTypeCtrl = TextEditingController(
      text: _readableUserType(widget.user.userType),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _userTypeCtrl.dispose();
    super.dispose();
  }

  static String _readableUserType(String? raw) {
    return switch (raw) {
      'horticultor-urbano' => 'Horticultor urbano',
      'micro-agricultor-periurbano' => 'Micro-agricultor periurbano',
      _ => raw ?? '',
    };
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final authBloc = context.read<AuthBloc>();

    try {
      final bytes = await picked.readAsBytes();
      final base64Image = base64Encode(bytes);
      final ext = picked.path.split('.').last.toLowerCase();
      final dataUrl = 'data:image/$ext;base64,$base64Image';

      final user = await _patchMe({'avatarUrl': dataUrl});
      if (!mounted) return;
      if (user != null) {
        authBloc.add(UserUpdated(user));
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.t('profileUpdated'))),
        );
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.t('errorGeneric'))));
    }
  }

  Future<User?> _patchMe(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);
    if (token == null) return null;

    final response = await http.patch(
      Uri.parse('${AppConstants.apiBaseUrl}/api/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200) return null;

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final publicUser = decoded['user'] as Map<String, dynamic>? ?? decoded;
    final profile = publicUser['profile'] as Map<String, dynamic>? ?? const {};
    final email = publicUser['email'] as String;
    final rawName = profile['fullName'] as String? ?? email;
    final name = rawName.contains('@') ? rawName.split('@').first : rawName;
    return UserModel(
      id: publicUser['id'] as String,
      name: name,
      email: email,
      phone: publicUser['phone'] as String?,
      avatarUrl: publicUser['avatarUrl'] as String?,
      userType: profile['profileType'] as String?,
    );
  }

  Future<void> _saveProfile() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final authBloc = context.read<AuthBloc>();

    setState(() => _saving = true);
    try {
      final user = await _patchMe({'fullName': _nameCtrl.text.trim()});

      if (!mounted) return;
      if (user != null) {
        authBloc.add(UserUpdated(user));
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.t('profileUpdated'))),
        );
      } else {
        messenger.showSnackBar(SnackBar(content: Text(l10n.t('errorGeneric'))));
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.t('errorGeneric'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                    onEditTap: _pickAndUploadPhoto,
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
                      onEditTap: _pickAndUploadPhoto,
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
                  onPressed: _saving ? null : _saveProfile,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
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
  final TextEditingController userTypeCtrl;

  const _ProfileFields({
    required this.nameCtrl,
    required this.emailCtrl,
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
            readOnly: true,
          ),
          _EditableProfileField(
            label: l10n.t('userType'),
            controller: userTypeCtrl,
            icon: Icons.badge_outlined,
            readOnly: true,
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
            fields[2],
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
  final bool readOnly;

  const _EditableProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: tt.labelLarge?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.78),
                letterSpacing: 0,
              ),
            ),
            if (readOnly) ...[
              const SizedBox(width: 6),
              Text(
                '(solo lectura)',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.40),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: tt.bodyMedium?.copyWith(
            color: readOnly
                ? cs.onSurface.withValues(alpha: 0.54)
                : cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 19),
            filled: true,
            fillColor: readOnly
                ? cs.surfaceContainerHighest.withValues(alpha: 0.54)
                : cs.surface.withValues(alpha: 0.82),
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
              borderSide: BorderSide(
                color: readOnly
                    ? cs.outline.withValues(alpha: 0.18)
                    : cs.primary,
                width: 1.5,
              ),
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
