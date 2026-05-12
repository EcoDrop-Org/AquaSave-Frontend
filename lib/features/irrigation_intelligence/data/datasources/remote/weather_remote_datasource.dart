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
    final requestedParts = _locationParts(location);

    for (final candidate in candidates) {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': candidate,
        'count': '10',
        'language': 'es',
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

      final ranked =
          results
              .whereType<Map<String, dynamic>>()
              .map(
                (result) => (
                  result: result,
                  score: _locationScore(result, requestedParts, candidate),
                ),
              )
              .toList()
            ..sort((a, b) => b.score.compareTo(a.score));

      if (ranked.isEmpty) continue;

      final best = ranked.first.result;
      return _ResolvedLocation(
        name: _displayName(best),
        latitude: (best['latitude'] as num).toDouble(),
        longitude: (best['longitude'] as num).toDouble(),
      );
    }

    throw const ServerException(
      'No se encontro una ubicacion valida para el huerto',
    );
  }

  List<String> _locationCandidates(String location) {
    final normalized = location.trim();
    final parts = _locationParts(normalized);

    return <String>{
      normalized,
      parts.join(' '),
      ...parts,
      if (parts.isNotEmpty) parts.last,
    }.where((candidate) => candidate.length >= 3).toList();
  }

  List<String> _locationParts(String location) {
    return location
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.length >= 3)
        .toList();
  }

  int _locationScore(
    Map<String, dynamic> result,
    List<String> requestedParts,
    String candidate,
  ) {
    final name = _normalize(result['name'] as String? ?? '');
    final admin1 = _normalize(result['admin1'] as String? ?? '');
    final admin2 = _normalize(result['admin2'] as String? ?? '');
    final country = _normalize(result['country'] as String? ?? '');
    final candidateText = _normalize(candidate);
    final haystack = [name, admin1, admin2, country].join(' ');
    var score = 0;

    if (requestedParts.isNotEmpty) {
      final main = _normalize(requestedParts.first);
      if (name == main) score += 90;
      if (name.contains(main)) score += 45;
      if (haystack.contains(main)) score += 25;
    }

    for (final part in requestedParts.skip(1)) {
      final normalizedPart = _normalize(part);
      if (admin1 == normalizedPart || admin2 == normalizedPart) score += 45;
      if (haystack.contains(normalizedPart)) score += 22;
    }

    if (candidateText == name || candidateText == '$name $admin1') score += 18;

    final population = (result['population'] as num?)?.toInt() ?? 0;
    score += (population / 250000).clamp(0, 12).round();

    return score;
  }

  String _normalize(String value) {
    const accents = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };

    var output = value.trim().toLowerCase();
    accents.forEach((from, to) => output = output.replaceAll(from, to));
    return output.replaceAll(RegExp(r'\s+'), ' ');
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
    final admin2 = result['admin2'] as String? ?? '';
    final admin1 = result['admin1'] as String? ?? '';
    final country = result['country'] as String? ?? '';
    return [
      name,
      if (admin2.isNotEmpty && admin2 != name) admin2,
      if (admin1.isNotEmpty && admin1 != name) admin1,
      country,
    ].where((part) => part.isNotEmpty).join(', ');
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
