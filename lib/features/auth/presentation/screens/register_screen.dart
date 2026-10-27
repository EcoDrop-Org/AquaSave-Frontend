import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/auth_top_bar.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_link_row.dart';
import '../widgets/auth_panel.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_underline_field.dart';
import '../../domain/entities/user_segment.dart';



class RegisterScreen extends StatefulWidget {
  final VoidCallback onGoToLogin;
  final VoidCallback onRegisterSuccess;

  const RegisterScreen({
    super.key,
    required this.onGoToLogin,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  UserSegment _selectedSegment = UserSegment.beginner;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    setState(() {
      _nameError = name.isEmpty ? l10n.t('fieldRequired') : null;
      _emailError = email.isEmpty
          ? l10n.t('fieldRequired')
          : (!email.contains('@') ? l10n.t('invalidEmail') : null);
      _passwordError = password.isEmpty ? l10n.t('fieldRequired') : null;
      _confirmError = confirm.isEmpty
          ? l10n.t('fieldRequired')
          : (confirm != password ? l10n.t('passwordMismatch') : null);
    });

    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }

    context.read<AuthBloc>().add(
      RegisterRequested(
        username: name,
        email: email,
        password: password,
        profileType: _selectedSegment.apiValue,
      ),
    );
  }

  void _setSegment(UserSegment value) {
    setState(() => _selectedSegment = value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          TextInput.finishAutofillContext();
          widget.onRegisterSuccess();
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              final body = isWide
                  ? _WideLayout(
                      nameCtrl: _nameCtrl,
                      emailCtrl: _emailCtrl,
                      passwordCtrl: _passwordCtrl,
                      confirmCtrl: _confirmCtrl,
                      selectedSegment: _selectedSegment,
                      onSegmentChanged: _setSegment,
                      isLoading: isLoading,
                      onSubmit: _submit,
                      onGoToLogin: widget.onGoToLogin,
                      nameError: _nameError,
                      emailError: _emailError,
                      passwordError: _passwordError,
                      confirmError: _confirmError,
                    )
                  : _NarrowLayout(
                      nameCtrl: _nameCtrl,
                      emailCtrl: _emailCtrl,
                      passwordCtrl: _passwordCtrl,
                      confirmCtrl: _confirmCtrl,
                      selectedSegment: _selectedSegment,
                      onSegmentChanged: _setSegment,
                      isLoading: isLoading,
                      onSubmit: _submit,
                      onGoToLogin: widget.onGoToLogin,
                      nameError: _nameError,
                      emailError: _emailError,
                      passwordError: _passwordError,
                      confirmError: _confirmError,
                    );
              return Stack(
                children: [
                  Positioned.fill(child: body),
                  const Positioned(top: 0, right: 0, child: AuthTopBar()),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _WideLayout extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final UserSegment selectedSegment;
  final ValueChanged<UserSegment> onSegmentChanged;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToLogin;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;

  const _WideLayout({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.selectedSegment,
    required this.onSegmentChanged,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToLogin,
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmError,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 10, child: AuthHeroPanel()),
        Expanded(
          flex: 10,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: AuthFormCard(
                    child: _FormContent(
                      nameCtrl: nameCtrl,
                      emailCtrl: emailCtrl,
                      passwordCtrl: passwordCtrl,
                      confirmCtrl: confirmCtrl,
                      selectedSegment: selectedSegment,
                      onSegmentChanged: onSegmentChanged,
                      isLoading: isLoading,
                      onSubmit: onSubmit,
                      onGoToLogin: onGoToLogin,
                      nameError: nameError,
                      emailError: emailError,
                      passwordError: passwordError,
                      confirmError: confirmError,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final UserSegment selectedSegment;
  final ValueChanged<UserSegment> onSegmentChanged;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToLogin;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;

  const _NarrowLayout({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.selectedSegment,
    required this.onSegmentChanged,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToLogin,
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmError,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          const SizedBox(
            height: 218,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppDimensions.radiusHero + 8),
              ),
              child: AuthHeroPanel(compact: true),
            ),
          ),
          Container(
            transform: Matrix4.translationValues(0, -26, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            constraints: const BoxConstraints(maxWidth: 560),
            child: AuthFormCard(
              child: _FormContent(
                nameCtrl: nameCtrl,
                emailCtrl: emailCtrl,
                passwordCtrl: passwordCtrl,
                confirmCtrl: confirmCtrl,
                selectedSegment: selectedSegment,
                onSegmentChanged: onSegmentChanged,
                isLoading: isLoading,
                onSubmit: onSubmit,
                onGoToLogin: onGoToLogin,
                nameError: nameError,
                emailError: emailError,
                passwordError: passwordError,
                confirmError: confirmError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final UserSegment selectedSegment;
  final ValueChanged<UserSegment> onSegmentChanged;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToLogin;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;

  const _FormContent({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.selectedSegment,
    required this.onSegmentChanged,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToLogin,
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmError,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AuthFormHeading(
          title: l10n.t('createAccount'),
          subtitle: l10n.t('registerSubtitle'),
        ),
        const SizedBox(height: 28),
        AutofillGroup(
          child: Column(
            children: [
              AuthUnderlineField(
                label: l10n.t('fullName'),
                controller: nameCtrl,
                errorText: nameError,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              AuthUnderlineField(
                label: l10n.t('email'),
                controller: emailCtrl,
                errorText: emailError,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              _ProfileTypeSelector(
                selectedValue: selectedSegment,
                onChanged: onSegmentChanged,
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              AuthUnderlineField(
                label: l10n.t('password'),
                controller: passwordCtrl,
                obscureText: true,
                errorText: passwordError,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              AuthUnderlineField(
                label: l10n.t('confirmPassword'),
                controller: confirmCtrl,
                obscureText: true,
                errorText: confirmError,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        Align(
          alignment: Alignment.centerRight,
          child: AuthLinkRow(
            prefixText: l10n.t('hasAccount'),
            linkText: l10n.t('loginLink'),
            onTap: onGoToLogin,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXl),
        AuthPrimaryButton(
          label: l10n.t('register'),
          onPressed: onSubmit,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _ProfileTypeSelector extends StatelessWidget {
  final UserSegment selectedValue;
  final ValueChanged<UserSegment> onChanged;

  const _ProfileTypeSelector({
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // El segmento elegido aqui define como se presenta la informacion en toda
    // la app (ver informe 1.3): al principiante se le explica cada lectura, al
    // experto se le muestran los datos y los controles de riego.
    final options = [
      _ProfileTypeOptionData(
        value: UserSegment.beginner,
        label: l10n.t('segmentBeginner'),
        hint: l10n.t('segmentBeginnerHint'),
        icon: Icons.school_outlined,
      ),
      _ProfileTypeOptionData(
        value: UserSegment.expert,
        label: l10n.t('segmentExpert'),
        hint: l10n.t('segmentExpertHint'),
        icon: Icons.tune_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('profileTypePrompt'),
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.68),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 430;
            if (stacked) {
              return Column(
                children: [
                  for (final option in options) ...[
                    _ProfileTypeOption(
                      option: option,
                      selected: option.value == selectedValue,
                      onTap: () => onChanged(option.value),
                    ),
                    if (option != options.last)
                      const SizedBox(height: AppDimensions.spaceSm),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (final option in options) ...[
                  Expanded(
                    child: _ProfileTypeOption(
                      option: option,
                      selected: option.value == selectedValue,
                      onTap: () => onChanged(option.value),
                    ),
                  ),
                  if (option != options.last)
                    const SizedBox(width: AppDimensions.spaceSm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProfileTypeOptionData {
  final UserSegment value;
  final String label;
  final String hint;
  final IconData icon;

  const _ProfileTypeOptionData({
    required this.value,
    required this.label,
    required this.hint,
    required this.icon,
  });
}

class _ProfileTypeOption extends StatelessWidget {
  final _ProfileTypeOptionData option;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileTypeOption({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.onPrimary : cs.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? cs.primary : cs.outline.withValues(alpha: 0.22),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(option.icon, color: fg, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.hint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(
                        color: fg.withValues(alpha: 0.78),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle_rounded, color: fg, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
