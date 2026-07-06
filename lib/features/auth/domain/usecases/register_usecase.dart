import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase
    implements UseCase<({User user, String token}), RegisterParams> {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, ({User user, String token})>> call(
    RegisterParams params,
  ) {
    return repository.register(
      username: params.username,
      email: params.email,
      password: params.password,
      profileType: params.profileType,
    );
  }
}

class RegisterParams extends Equatable {
  final String username;
  final String email;
  final String password;
  final String profileType;

  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
    required this.profileType,
  });

  @override
  List<Object> get props => [username, email, password, profileType];
}
