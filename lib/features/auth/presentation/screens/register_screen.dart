import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_link_row.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_underline_field.dart';

/// Frame 2 — Register.
/// Igual que Login pero con campo extra "Confirmar Contraseña".
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
  final _usernameCtrl  = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    context.read<AuthBloc>().add(
          RegisterRequested(
            username: _usernameCtrl.text.trim(),
            email: '',
            password: _passwordCtrl.text,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              return isWide
                  ? _WideLayout(
                      usernameCtrl: _usernameCtrl,
                      passwordCtrl: _passwordCtrl,
                      confirmCtrl: _confirmCtrl,
                      isLoading: isLoading,
                      onSubmit: _submit,
                      onGoToLogin: widget.onGoToLogin,
                    )
                  : _NarrowLayout(
                      usernameCtrl: _usernameCtrl,
                      passwordCtrl: _passwordCtrl,
                      confirmCtrl: _confirmCtrl,
                      isLoading: isLoading,
                      onSubmit: _submit,
                      onGoToLogin: widget.onGoToLogin,
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

  const _WideLayout({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox.expand(
            child: Image.asset(
              AppConstants.imgLoginPlant,
              fit: BoxFit.cover,
            ),
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

  const _NarrowLayout({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToLogin,
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

  const _FormContent({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToLogin,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppConstants.titleWelcome,
          style: tt.displayLarge?.copyWith(color: const Color(0xFF2D3D2C)),
        ),
        const SizedBox(height: 80),
        AuthUnderlineField(
          label: AppConstants.labelUsername,
          controller: usernameCtrl,
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        AuthUnderlineField(
          label: AppConstants.labelPassword,
          controller: passwordCtrl,
          obscureText: true,
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        AuthUnderlineField(
          label: AppConstants.labelConfirmPwd,
          controller: confirmCtrl,
          obscureText: true,
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        Align(
          alignment: Alignment.centerRight,
          child: AuthLinkRow(
            prefixText: AppConstants.hasAccount,
            linkText: AppConstants.linkLogin,
            onTap: onGoToLogin,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXl),
        AuthPrimaryButton(
          label: AppConstants.btnLogin,
          onPressed: onSubmit,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
