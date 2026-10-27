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
