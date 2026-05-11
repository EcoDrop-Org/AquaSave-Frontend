import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, ({User user, String token})>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, ({User user, String token})>> register({
    required String username,
    required String email,
    required String password,
  });
}
