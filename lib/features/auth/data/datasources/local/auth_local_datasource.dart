import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<({UserModel user, String token})> login({
    required String username,
    required String password,
  });

  Future<({UserModel user, String token})> register({
    required String username,
    required String email,
    required String password,
    required String profileType,
  });
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<({UserModel user, String token})> login({
    required String username,
    required String password,
  }) async {
    try {
      final jsonString = await rootBundle.loadString(AppConstants.mockAuthPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;
      return (user: user, token: token);
    } catch (_) {
      throw const CacheException('No se pudo cargar auth.json');
    }
  }

  @override
  Future<({UserModel user, String token})> register({
    required String username,
    required String email,
    required String password,
    required String profileType,
  }) async {
    // Mock: devuelve el mismo usuario del JSON con los datos proporcionados
    try {
      final jsonString = await rootBundle.loadString(AppConstants.mockAuthPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final baseUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final mockUser = UserModel(
        id: baseUser.id,
        name: username,
        email: email,
        avatarUrl: baseUser.avatarUrl,
        userType: profileType,
      );
      final token = data['token'] as String;
      return (user: mockUser, token: token);
    } catch (_) {
      throw const CacheException('No se pudo cargar auth.json');
    }
  }
}
