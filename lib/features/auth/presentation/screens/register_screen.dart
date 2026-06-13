import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/auth_top_bar.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_link_row.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_underline_field.dart';

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
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _usernameError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    setState(() {
      _usernameError = username.isEmpty ? l10n.t('fieldRequired') : null;
      _passwordError = password.isEmpty ? l10n.t('fieldRequired') : null;
      _confirmError = confirm.isEmpty
          ? l10n.t('fieldRequired')
          : (confirm != password ? l10n.t('passwordMismatch') : null);
    });

    if (_usernameError != null || _passwordError != null || _confirmError != null) return;

    context.read<AuthBloc>().add(
      RegisterRequested(
        username: username,
        email: '',
        password: password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
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
                      usernameCtrl: _usernameCtrl,
                      passwordCtrl: _passwordCtrl,
                      confirmCtrl: _confirmCtrl,
                      isLoading: isLoading,
                      onSubmit: _submit,
                      onGoToLogin: widget.onGoToLogin,
                      usernameError: _usernameError,
                      passwordError: _passwordError,
                      confirmError: _confirmError,
                    )
                  : _NarrowLayout(
                      usernameCtrl: _usernameCtrl,
                      passwordCtrl: _passwordCtrl,
                      confirmCtrl: _confirmCtrl,
                      isLoading: isLoading,
                      onSubmit: _submit,
                      onGoToLogin: widget.onGoToLogin,
                      usernameError: _usernameError,
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
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToLogin;
  final String? usernameError;
  final String? passwordError;
  final String? confirmError;

  const _WideLayout({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToLogin,
    this.usernameError,
    this.passwordError,
    this.confirmError,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox.expand(
            child: Image.asset(AppConstants.imgLoginPlant, fit: BoxFit.cover),
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
            child: _FormContent(
              usernameCtrl: usernameCtrl,
              passwordCtrl: passwordCtrl,
              confirmCtrl: confirmCtrl,
              isLoading: isLoading,
              onSubmit: onSubmit,
              onGoToLogin: onGoToLogin,
              usernameError: usernameError,
              passwordError: passwordError,
              confirmError: confirmError,
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToLogin;
  final String? usernameError;
  final String? passwordError;
  final String? confirmError;

  const _NarrowLayout({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToLogin,
    this.usernameError,
    this.passwordError,
    this.confirmError,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: _FormContent(
        usernameCtrl: usernameCtrl,
        passwordCtrl: passwordCtrl,
        confirmCtrl: confirmCtrl,
        isLoading: isLoading,
        onSubmit: onSubmit,
        onGoToLogin: onGoToLogin,
        usernameError: usernameError,
        passwordError: passwordError,
        confirmError: confirmError,
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToLogin;
  final String? usernameError;
  final String? passwordError;
  final String? confirmError;

  const _FormContent({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToLogin,
    this.usernameError,
    this.passwordError,
    this.confirmError,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppLogo(height: 74),
        const SizedBox(height: 24),
        Text(
          l10n.t('createAccount'),
          style: tt.displayLarge?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 40),
        AuthUnderlineField(
          label: l10n.t('username'),
          controller: usernameCtrl,
          errorText: usernameError,
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        AuthUnderlineField(
          label: l10n.t('password'),
          controller: passwordCtrl,
          obscureText: true,
          errorText: passwordError,
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        AuthUnderlineField(
          label: l10n.t('confirmPassword'),
          controller: confirmCtrl,
          obscureText: true,
          errorText: confirmError,
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
