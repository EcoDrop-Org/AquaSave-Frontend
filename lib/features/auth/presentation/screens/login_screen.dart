import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_link_row.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_underline_field.dart';

/// Frame 1 — Login.
/// Layout: mitad izquierda = imagen de planta, mitad derecha = formulario.
/// En móvil: columna única con fondo de color.
class LoginScreen extends StatefulWidget {
  final VoidCallback onGoToRegister;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onGoToRegister,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthBloc>().add(
          LoginRequested(
            username: _usernameCtrl.text.trim(),
            password: _passwordCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          widget.onLoginSuccess();
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
                      isLoading: isLoading,
                      onSubmit: _submit,
                      onGoToRegister: widget.onGoToRegister,
                    )
                  : _NarrowLayout(
                      usernameCtrl: _usernameCtrl,
                      passwordCtrl: _passwordCtrl,
                      isLoading: isLoading,
                      onSubmit: _submit,
                      onGoToRegister: widget.onGoToRegister,
                    );
            },
          ),
        );
      },
    );
  }
}

// ── Wide layout (tablet/desktop) ─────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToRegister;

  const _WideLayout({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left half — plant image
        Expanded(
          child: SizedBox.expand(
            child: Image.asset(
              AppConstants.imgLoginPlant,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Right half — form
        Expanded(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
            child: _FormContent(
              usernameCtrl: usernameCtrl,
              passwordCtrl: passwordCtrl,
              isLoading: isLoading,
              onSubmit: onSubmit,
              onGoToRegister: onGoToRegister,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Narrow layout (mobile) ────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToRegister;

  const _NarrowLayout({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToRegister,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: _FormContent(
        usernameCtrl: usernameCtrl,
        passwordCtrl: passwordCtrl,
        isLoading: isLoading,
        onSubmit: onSubmit,
        onGoToRegister: onGoToRegister,
      ),
    );
  }
}

// ── Shared form content ───────────────────────────────────────────────────────

class _FormContent extends StatelessWidget {
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToRegister;

  const _FormContent({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToRegister,
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
        const SizedBox(height: AppDimensions.spaceXs),
        Align(
          alignment: Alignment.centerRight,
          child: AuthLinkRow(
            prefixText: AppConstants.noAccount,
            linkText: AppConstants.linkRegister,
            onTap: onGoToRegister,
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
