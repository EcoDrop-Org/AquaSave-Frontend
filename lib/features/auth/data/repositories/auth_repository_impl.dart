import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final bool useMock;

  const AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.useMock,
  });

  @override
  Future<Either<Failure, ({User user, String token})>> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = useMock
          ? await localDataSource.login(username: username, password: password)
          : await remoteDataSource.login(
              username: username,
              password: password,
            );
      return Right((user: result.user, token: result.token));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ({User user, String token})>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final result = useMock
          ? await localDataSource.register(
              username: username,
              email: email,
              password: password,
            )
          : await remoteDataSource.register(
              username: username,
              email: email,
              password: password,
            );
      return Right((user: result.user, token: result.token));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
