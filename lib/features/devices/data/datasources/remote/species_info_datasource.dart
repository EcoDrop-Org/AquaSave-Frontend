import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';

/// Ficha de una especie: foto y descripción que el backend busca en Wikipedia.
class SpeciesInfo {
  final String? description;
  final String? imageUrl;

  const SpeciesInfo({this.description, this.imageUrl});
}

abstract class SpeciesInfoDataSource {
  // GET /api/irrigation/species-info?ids=albahaca,menta
  Future<Map<String, SpeciesInfo>> fetch(List<String> speciesIds);

  // GET /api/irrigation/plants-info — ficha por dispositivo.
  Future<Map<String, SpeciesInfo>> fetchForPlants();

  // GET /api/irrigation/devices/{id}/fact
  Future<String?> fetchFact(String deviceId);
}

class HttpSpeciesInfoDataSource implements SpeciesInfoDataSource {
  final http.Client client;

  const HttpSpeciesInfoDataSource({required this.client});

  @override
  Future<Map<String, SpeciesInfo>> fetch(List<String> speciesIds) async {
    final ids = speciesIds.where((id) => id.trim().isNotEmpty).toSet();
    if (ids.isEmpty) return const {};

    final response = await client.get(
      Uri.parse(
        '${AppConstants.apiBaseUrl}/api/irrigation/species-info',
      ).replace(queryParameters: {'ids': ids.join(',')}),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw const ServerException('No se pudo cargar la ficha de la planta');
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) return const {};
    final species = decoded['species'];
    if (species is! Map<String, dynamic>) return const {};

    return {
      for (final entry in species.entries)
        if (entry.value case final Map<String, dynamic> value)
          entry.key: SpeciesInfo(
            description: _text(value['description']),
            imageUrl: _text(value['imageUrl']),
          ),
    };
  }

  @override
  Future<Map<String, SpeciesInfo>> fetchForPlants() async {
    final response = await client.get(
      Uri.parse('${AppConstants.apiBaseUrl}/api/irrigation/plants-info'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) return const {};

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) return const {};
    final plants = decoded['plants'];
    if (plants is! Map<String, dynamic>) return const {};

    return {
      for (final entry in plants.entries)
        if (entry.value case final Map<String, dynamic> value)
          entry.key: SpeciesInfo(
            description: _text(value['description']),
            imageUrl: _text(value['imageUrl']),
          ),
    };
  }

  @override
  Future<String?> fetchFact(String deviceId) async {
    final response = await client.get(
      Uri.parse(
        '${AppConstants.apiBaseUrl}/api/irrigation/devices/$deviceId/fact',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) return null;
    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final fact = decoded['fact'];
    return fact is Map<String, dynamic> ? _text(fact['text']) : null;
  }

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);
    if (token == null || token.isEmpty) {
      throw const ServerException('No hay una sesion activa');
    }
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static String? _text(Object? value) {
    final text = value is String ? value.trim() : '';
    return text.isEmpty ? null : text;
  }
}
