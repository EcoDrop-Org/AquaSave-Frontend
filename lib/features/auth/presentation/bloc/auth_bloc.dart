import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
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

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }
}
