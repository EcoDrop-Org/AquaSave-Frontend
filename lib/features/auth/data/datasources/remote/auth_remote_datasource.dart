import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  // TODO: POST /api/auth/login — body: {username, password}
  Future<({UserModel user, String token})> login({
    required String username,
    required String password,
  });

  // TODO: POST /api/auth/register — body: {username, email, password}
  Future<({UserModel user, String token})> register({
    required String username,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<({UserModel user, String token})> login({
    required String username,
    required String password,
  }) {
    // TODO: conectar endpoint POST /api/auth/login
    throw UnimplementedError();
  }

  @override
  Future<({UserModel user, String token})> register({
    required String username,
    required String email,
    required String password,
  }) {
    // TODO: conectar endpoint POST /api/auth/register
    throw UnimplementedError();
  }
}
