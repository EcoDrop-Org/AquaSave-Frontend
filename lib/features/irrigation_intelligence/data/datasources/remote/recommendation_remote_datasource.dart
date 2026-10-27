import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/plant_recommendation_model.dart';

abstract class RecommendationRemoteDataSource {
  // GET /api/irrigation/devices/{deviceId}/recommendation
  Future<PlantRecommendationModel> getRecommendation(String deviceId);
}

class HttpRecommendationRemoteDataSource
    implements RecommendationRemoteDataSource {
  final http.Client client;

  const HttpRecommendationRemoteDataSource({required this.client});

  @override
  Future<PlantRecommendationModel> getRecommendation(String deviceId) async {
    final response = await client.get(
      Uri.parse(
        '${AppConstants.apiBaseUrl}'
        '/api/irrigation/devices/$deviceId/recommendation',
      ),
      headers: await _authHeaders(),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200) {
      throw ServerException(
        _errorMessage(body, 'No se pudo cargar la recomendación'),
      );
    }

    final recommendation = body['recommendation'] as Map<String, dynamic>?;
    if (recommendation == null) {
      throw const ServerException('Respuesta de recomendación invalida');
    }

    return PlantRecommendationModel.fromJson(recommendation);
  }

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);
    if (token == null || token.isEmpty) {
      throw const ServerException('No hay una sesion activa');
    }

    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeBody(String responseBody) {
    final decoded = json.decode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const ServerException('Respuesta de recomendación invalida');
    }
    return decoded;
  }

  String _errorMessage(Map<String, dynamic> body, String fallback) {
    final message = body['message'];
    return message is String && message.isNotEmpty ? message : fallback;
  }
}
