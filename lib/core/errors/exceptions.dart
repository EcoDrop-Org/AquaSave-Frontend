class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Error del servidor']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Error de caché local']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Credenciales incorrectas']);
}
