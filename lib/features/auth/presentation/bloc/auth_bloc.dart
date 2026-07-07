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

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthCheckingSession());
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);
    if (token == null || token.isEmpty) {
      emit(const AuthInitial());
      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/api/auth/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          // El backend en Render free puede tardar en "despertar"; sin este
          // timeout la verificacion de sesion se colgaria indefinidamente.
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        await prefs.remove(AppConstants.authTokenKey);
        await prefs.remove(AppConstants.authExpiresAtKey);
        emit(const AuthInitial());
        return;
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      final publicUser = body['user'] as Map<String, dynamic>;
      final profile =
          publicUser['profile'] as Map<String, dynamic>? ?? const {};
      final email = publicUser['email'] as String;
      final rawName = profile['fullName'] as String? ?? email;
      final name = rawName.contains('@') ? rawName.split('@').first : rawName;
      final user = UserModel(
        id: publicUser['id'] as String,
        name: name,
        email: email,
        phone: publicUser['phone'] as String?,
        avatarUrl: publicUser['avatarUrl'] as String?,
        userType: profile['profileType'] as String?,
      );
      emit(AuthAuthenticated(user: user, token: token));
    } catch (_) {
      emit(const AuthInitial());
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
        profileType: event.profileType,
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
