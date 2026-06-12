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
    final response = await client.post(
      _uri('/api/auth/login'),
      headers: _jsonHeaders,
      body: json.encode({'email': username, 'password': password}),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200) {
      _throwApiException(response.statusCode, body, 'No se pudo iniciar sesion');
    }

    final token = body['token'] as String;
    await _saveSession(
      token: token,
      expiresAt: body['expiresAt'] as String?,
    );

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
  }) async {
    final effectiveEmail = email.trim().isNotEmpty ? email.trim() : username;
    final response = await client.post(
      _uri('/api/auth/register'),
      headers: _jsonHeaders,
      body: json.encode({
        'email': effectiveEmail,
        'password': password,
        'fullName': username,
      }),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      _throwApiException(response.statusCode, body, 'No se pudo registrar');
    }

    final token = body['token'] as String;
    await _saveSession(
      token: token,
      expiresAt: body['expiresAt'] as String?,
    );

    return (
      user: _userFromPublicUser(body['user'] as Map<String, dynamic>),
      token: token,
    );
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
    return UserModel(
      id: json['id'] as String,
      name: profile['fullName'] as String? ?? json['email'] as String,
      email: json['email'] as String,
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
