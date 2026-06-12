import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/weather_forecast_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherForecastModel> getCurrentWeather({
    required String deviceId,
    required String location,
    double? latitude,
    double? longitude,
  });
}

class OpenMeteoWeatherRemoteDataSource implements WeatherRemoteDataSource {
  final http.Client client;

  const OpenMeteoWeatherRemoteDataSource({required this.client});

  @override
  Future<WeatherForecastModel> getCurrentWeather({
    required String deviceId,
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    final response = await client.get(
      _uri('/api/weather/forecast', {'deviceId': deviceId}),
      headers: await _authHeaders(),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200) {
      throw ServerException(_errorMessage(body, 'No se pudo cargar el clima'));
    }

    final forecast = body['forecast'] as Map<String, dynamic>?;
    if (forecast == null) {
      throw const ServerException('Respuesta de clima invalida');
    }

    return _forecastFromApi(
      forecast,
      fallbackDeviceId: deviceId,
      fallbackLocation: location,
      fallbackLatitude: latitude,
      fallbackLongitude: longitude,
    );
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse(
      '${AppConstants.apiBaseUrl}$path',
    ).replace(queryParameters: queryParameters);
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
      throw const ServerException('Respuesta de clima invalida');
    }
    return decoded;
  }

  WeatherForecastModel _forecastFromApi(
    Map<String, dynamic> json, {
    required String fallbackDeviceId,
    required String fallbackLocation,
    double? fallbackLatitude,
    double? fallbackLongitude,
  }) {
    return WeatherForecastModel(
      deviceId: json['deviceId'] as String? ?? fallbackDeviceId,
      locationName: json['locationName'] as String? ?? fallbackLocation,
      latitude: fallbackLatitude ?? 0,
      longitude: fallbackLongitude ?? 0,
      temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 0,
      apparentTemperatureC:
          (json['apparentTemperatureC'] as num?)?.toDouble() ?? 0,
      humidityPct: (json['humidityPct'] as num?)?.toInt() ?? 0,
      rainProbabilityPct:
          (json['rainProbabilityPct'] as num?)?.toInt() ?? 0,
      precipitationMm: (json['precipitationMm'] as num?)?.toDouble() ?? 0,
      windSpeedKmh: (json['windSpeedKmh'] as num?)?.toDouble() ?? 0,
      weatherCode: 0,
      conditionLabel: json['conditionLabel'] as String? ?? 'Clima variable',
      isDay: true,
      retrievedAt: _parseDate(json['retrievedAt']) ?? DateTime.now(),
      validUntil:
          _parseDate(json['validUntil']) ??
          DateTime.now().add(const Duration(minutes: 30)),
    );
  }

  DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _errorMessage(Map<String, dynamic> body, String fallback) {
    final message = body['message'];
    return message is String && message.isNotEmpty ? message : fallback;
  }
}
