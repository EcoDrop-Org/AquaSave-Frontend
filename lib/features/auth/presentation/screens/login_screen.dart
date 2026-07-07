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

/// Frame 1 — Login.
/// Layout ancho: imagen botánica con marca a la izquierda + tarjeta flotante
/// con el formulario a la derecha. En móvil: franja de imagen arriba y la
/// tarjeta del formulario superpuesta.
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
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() {
      _usernameError = username.isEmpty ? l10n.t('fieldRequired') : null;
      _passwordError = password.isEmpty ? l10n.t('fieldRequired') : null;
    });

    if (_usernameError != null || _passwordError != null) return;

    context.read<AuthBloc>().add(
      LoginRequested(username: username, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          TextInput.finishAutofillContext();
          widget.onLoginSuccess();
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
                      isLoading: isLoading,
                      onSubmit: _submit,
                      onGoToRegister: widget.onGoToRegister,
                      usernameError: _usernameError,
                      passwordError: _passwordError,
                    )
                  : _NarrowLayout(
                      usernameCtrl: _usernameCtrl,
                      passwordCtrl: _passwordCtrl,
                      isLoading: isLoading,
                      onSubmit: _submit,
                      onGoToRegister: widget.onGoToRegister,
                      usernameError: _usernameError,
                      passwordError: _passwordError,
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

// ── Wide layout (tablet/desktop) ─────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToRegister;
  final String? usernameError;
  final String? passwordError;

  const _WideLayout({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToRegister,
    this.usernameError,
    this.passwordError,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Lado izquierdo — imagen botánica con la marca.
        const Expanded(flex: 11, child: AuthHeroPanel()),
        // Lado derecho — tarjeta flotante con el formulario.
        Expanded(
          flex: 9,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 470),
                  child: AuthFormCard(
                    child: _FormContent(
                      usernameCtrl: usernameCtrl,
                      passwordCtrl: passwordCtrl,
                      isLoading: isLoading,
                      onSubmit: onSubmit,
                      onGoToRegister: onGoToRegister,
                      usernameError: usernameError,
                      passwordError: passwordError,
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

// ── Narrow layout (mobile) ────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToRegister;
  final String? usernameError;
  final String? passwordError;

  const _NarrowLayout({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToRegister,
    this.usernameError,
    this.passwordError,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Franja de imagen con la marca; esquinas inferiores redondeadas.
          const SizedBox(
            height: 264,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppDimensions.radiusHero + 8),
              ),
              child: AuthHeroPanel(compact: true),
            ),
          ),
          // La tarjeta del formulario "flota" sobre la imagen.
          Container(
            transform: Matrix4.translationValues(0, -26, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            constraints: const BoxConstraints(maxWidth: 520),
            child: AuthFormCard(
              child: _FormContent(
                usernameCtrl: usernameCtrl,
                passwordCtrl: passwordCtrl,
                isLoading: isLoading,
                onSubmit: onSubmit,
                onGoToRegister: onGoToRegister,
                usernameError: usernameError,
                passwordError: passwordError,
              ),
            ),
          ),
        ],
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
  final String? usernameError;
  final String? passwordError;

  const _FormContent({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoToRegister,
    this.usernameError,
    this.passwordError,
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
          title: l10n.t('welcomeBack'),
          subtitle: l10n.t('loginSubtitle'),
        ),
        const SizedBox(height: 32),
        AutofillGroup(
          child: Column(
            children: [
              AuthUnderlineField(
                label: l10n.t('username'),
                controller: usernameCtrl,
                errorText: usernameError,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              AuthUnderlineField(
                label: l10n.t('password'),
                controller: passwordCtrl,
                obscureText: true,
                errorText: passwordError,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        Align(
          alignment: Alignment.centerRight,
          child: AuthLinkRow(
            prefixText: l10n.t('noAccount'),
            linkText: l10n.t('registerLink'),
            onTap: onGoToRegister,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXl),
        AuthPrimaryButton(
          label: l10n.t('login'),
          onPressed: onSubmit,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
