import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({required this.loginUseCase, required this.registerUseCase})
    : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UserUpdated>(_onUserUpdated);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCheckingSession());
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);
    if (token == null || token.isEmpty) return; // queda en AuthInitial

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        await prefs.remove(AppConstants.authTokenKey);
        await prefs.remove(AppConstants.authExpiresAtKey);
        return;
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      final publicUser = body['user'] as Map<String, dynamic>;
      final profile =
          publicUser['profile'] as Map<String, dynamic>? ?? const {};
      final user = UserModel(
        id: publicUser['id'] as String,
        name: profile['fullName'] as String? ?? publicUser['email'] as String,
        email: publicUser['email'] as String,
        avatarUrl: publicUser['avatarUrl'] as String?,
        userType: profile['profileType'] as String?,
      );
      emit(AuthAuthenticated(user: user, token: token));
    } catch (_) {
      // Sin red al arrancar: no se cierra sesión, se queda en AuthInitial
      // y el usuario puede reintentar iniciando sesión.
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      LoginParams(username: event.username, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (data) => emit(AuthAuthenticated(user: data.user, token: data.token)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await registerUseCase(
      RegisterParams(
        username: event.username,
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (data) => emit(AuthAuthenticated(user: data.user, token: data.token)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.authExpiresAtKey);
    emit(const AuthInitial());
  }

  void _onUserUpdated(UserUpdated event, Emitter<AuthState> emit) {
    final current = state;
    if (current is AuthAuthenticated) {
      emit(AuthAuthenticated(user: event.user, token: current.token));
    }
  }
}
