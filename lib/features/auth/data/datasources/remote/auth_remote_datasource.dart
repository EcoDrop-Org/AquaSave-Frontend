import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';
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
    required String profileType,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<({UserModel user, String token})> login({
    required String username,
    required String password,
  }) async {
    final response = await _post(
      '/api/auth/login',
      json.encode({'email': username, 'password': password}),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200) {
      _throwApiException(
        response.statusCode,
        body,
        'No se pudo iniciar sesion',
      );
    }

    final token = body['token'] as String;
    await _saveSession(token: token, expiresAt: body['expiresAt'] as String?);

    return (
      user: _userFromPublicUser(body['user'] as Map<String, dynamic>),
      token: token,
    );
  }

  @override
  Future<({UserModel user, String token})> register({
    required String username,
    required String email,
    required String password,
    required String profileType,
  }) async {
    final effectiveEmail = email.trim().isNotEmpty ? email.trim() : username;
    final response = await _post(
      '/api/auth/register',
      json.encode({
        'email': effectiveEmail,
        'password': password,
        'fullName': username,
        'profileType': profileType,
      }),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      _throwApiException(response.statusCode, body, 'No se pudo registrar');
    }

    final token = body['token'] as String;
    await _saveSession(token: token, expiresAt: body['expiresAt'] as String?);

    return (
      user: _userFromPublicUser(body['user'] as Map<String, dynamic>),
      token: token,
    );
  }

  // POST con timeout. El backend en Render free puede tardar en "despertar";
  // sin timeout la peticion se colgaria indefinidamente (spinner infinito).
  Future<http.Response> _post(String path, String body) async {
    try {
      return await client
          .post(_uri(path), headers: _jsonHeaders, body: body)
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw const ServerException(
        'El servidor tardo demasiado en responder. Puede estar iniciando; '
        'intenta de nuevo en unos segundos.',
      );
    } catch (_) {
      throw const ServerException(
        'No se pudo conectar con el servidor. Revisa tu conexion a internet.',
      );
    }
  }

  Uri _uri(String path) => Uri.parse('${AppConstants.apiBaseUrl}$path');

  Map<String, String> get _jsonHeaders => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, dynamic> _decodeBody(String responseBody) {
    final decoded = json.decode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const ServerException('Respuesta de autenticacion invalida');
    }
    return decoded;
  }

  UserModel _userFromPublicUser(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? const {};
    final email = json['email'] as String;
    final rawName = profile['fullName'] as String? ?? email;
    final name = rawName.contains('@') ? rawName.split('@').first : rawName;
    return UserModel(
      id: json['id'] as String,
      name: name,
      email: email,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      userType: profile['profileType'] as String?,
    );
  }

  Future<void> _saveSession({required String token, String? expiresAt}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.authTokenKey, token);
    if (expiresAt != null) {
      await prefs.setString(AppConstants.authExpiresAtKey, expiresAt);
    }
  }

  Never _throwApiException(
    int statusCode,
    Map<String, dynamic> body,
    String fallback,
  ) {
    final message = body['message'] as String? ?? fallback;
    if (statusCode == 401) throw AuthException(message);
    throw ServerException(message);
  }
}
