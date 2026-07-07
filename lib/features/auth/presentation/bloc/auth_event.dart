part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String profileType;

  const RegisterRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.profileType,
  });

  @override
  List<Object> get props => [username, email, password, profileType];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class UserUpdated extends AuthEvent {
  final User user;

  const UserUpdated(this.user);

  @override
  List<Object> get props => [user];
}
