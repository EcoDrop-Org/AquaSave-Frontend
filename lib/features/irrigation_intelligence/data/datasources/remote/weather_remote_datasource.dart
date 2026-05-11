import 'dart:convert';

import 'package:http/http.dart' as http;

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
    final resolved = latitude != null && longitude != null
        ? _ResolvedLocation(
            name: location,
            latitude: latitude,
            longitude: longitude,
          )
        : await _resolveLocation(location);

    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': resolved.latitude.toString(),
      'longitude': resolved.longitude.toString(),
      'current': [
        'temperature_2m',
        'relative_humidity_2m',
        'apparent_temperature',
        'is_day',
        'precipitation',
        'rain',
        'weather_code',
        'cloud_cover',
        'wind_speed_10m',
      ].join(','),
      'daily': 'precipitation_probability_max',
      'forecast_days': '1',
      'timezone': 'auto',
    });

    final response = await client.get(uri);
    final body = _decodeBody(response.body);

    if (response.statusCode != 200) {
      throw ServerException(_errorMessage(body, 'No se pudo cargar el clima'));
    }

    return WeatherForecastModel.fromOpenMeteo(
      deviceId: deviceId,
      locationName: resolved.name,
      requestedLatitude: resolved.latitude,
      requestedLongitude: resolved.longitude,
      json: body,
    );
  }

  Future<_ResolvedLocation> _resolveLocation(String location) async {
    final candidates = _locationCandidates(location);

    for (final candidate in candidates) {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': candidate,
        'count': '1',
        'language': 'es',
        'countryCode': 'PE',
      });

      final response = await client.get(uri);
      final body = _decodeBody(response.body);

      if (response.statusCode != 200) {
        throw ServerException(
          _errorMessage(body, 'No se pudo resolver la ubicacion del huerto'),
        );
      }

      final results = body['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) continue;

      final first = results.first as Map<String, dynamic>;
      return _ResolvedLocation(
        name: _displayName(first),
        latitude: (first['latitude'] as num).toDouble(),
        longitude: (first['longitude'] as num).toDouble(),
      );
    }

    throw const ServerException(
      'No se encontro una ubicacion valida para el huerto',
    );
  }

  List<String> _locationCandidates(String location) {
    final normalized = location.trim();
    final parts = normalized
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.length >= 3)
        .toList();

    return <String>{
      normalized,
      ...parts,
      if (parts.isNotEmpty) parts.last,
      'Lima',
    }.where((candidate) => candidate.length >= 3).toList();
  }

  Map<String, dynamic> _decodeBody(String body) {
    final decoded = json.decode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const ServerException('Respuesta de clima invalida');
    }
    return decoded;
  }

  String _errorMessage(Map<String, dynamic> body, String fallback) {
    final reason = body['reason'];
    return reason is String && reason.isNotEmpty ? reason : fallback;
  }

  String _displayName(Map<String, dynamic> result) {
    final name = result['name'] as String? ?? '';
    final admin1 = result['admin1'] as String? ?? '';
    final country = result['country'] as String? ?? '';
    return [name, admin1, country].where((part) => part.isNotEmpty).join(', ');
  }
}

class _ResolvedLocation {
  final String name;
  final double latitude;
  final double longitude;

  const _ResolvedLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}
