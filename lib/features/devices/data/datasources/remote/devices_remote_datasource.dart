import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../domain/entities/device.dart';
import '../../models/device_model.dart';

abstract class DevicesRemoteDataSource {
  // GET /api/devices
  Future<List<DeviceModel>> getDevices();

  // POST /api/devices
  Future<DeviceModel> addDevice({
    required String name,
    required String location,
    required int plantCount,
    double? latitude,
    double? longitude,
    String? description,
  });

  // PATCH /api/devices/{deviceId}
  Future<DeviceModel> updateDevice({
    required String deviceId,
    required String name,
    required String location,
    required int plantCount,
    double? latitude,
    double? longitude,
    String? description,
  });

  // DELETE /api/devices/{deviceId}
  Future<void> deleteDevice(String deviceId);
}

class DevicesRemoteDataSourceImpl implements DevicesRemoteDataSource {
  final http.Client client;

  DevicesRemoteDataSourceImpl({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<List<DeviceModel>> getDevices() async {
    final response = await client.get(
      _uri('/api/devices'),
      headers: await _authHeaders(),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200) {
      throw ServerException(_errorMessage(body, 'No se pudieron cargar dispositivos'));
    }

    final devices = body['devices'] as List<dynamic>? ?? const [];
    return devices
        .whereType<Map<String, dynamic>>()
        .map(_deviceFromApi)
        .toList();
  }

  @override
  Future<DeviceModel> addDevice({
    required String name,
    required String location,
    required int plantCount,
    double? latitude,
    double? longitude,
    String? description,
  }) async {
    final response = await client.post(
      _uri('/api/devices'),
      headers: await _authHeaders(json: true),
      body: json.encode(
        _devicePayload(
          name: name,
          location: location,
          plantCount: plantCount,
          latitude: latitude,
          longitude: longitude,
          description: description,
        ),
      ),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerException(
        _errorMessage(body, 'No se pudo registrar el dispositivo'),
      );
    }
    return _deviceFromBody(body);
  }

  @override
  Future<DeviceModel> updateDevice({
    required String deviceId,
    required String name,
    required String location,
    required int plantCount,
    double? latitude,
    double? longitude,
    String? description,
  }) async {
    final response = await client.patch(
      _uri('/api/devices/$deviceId'),
      headers: await _authHeaders(json: true),
      body: json.encode(
        _devicePayload(
          name: name,
          location: location,
          plantCount: plantCount,
          latitude: latitude,
          longitude: longitude,
          description: description,
          nullableCropType: true,
        ),
      ),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200) {
      throw ServerException(
        _errorMessage(body, 'No se pudo actualizar el dispositivo'),
      );
    }
    return _deviceFromBody(body);
  }

  @override
  Future<void> deleteDevice(String deviceId) async {
    final response = await client.delete(
      _uri('/api/devices/$deviceId'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      final body = response.body.isEmpty
          ? const <String, dynamic>{}
          : _decodeBody(response.body);
      throw ServerException(
        _errorMessage(body, 'No se pudo eliminar el dispositivo'),
      );
    }
  }

  Map<String, dynamic> _devicePayload({
    required String name,
    required String location,
    required int plantCount,
    double? latitude,
    double? longitude,
    String? description,
    bool nullableCropType = false,
  }) {
    final trimmedDescription = description?.trim() ?? '';
    final cropType =
        trimmedDescription.length >= 2 ? trimmedDescription : null;
    return {
      'name': name,
      'location': {
        'label': location,
        if (latitude != null && longitude != null) ...{
          'latitude': latitude,
          'longitude': longitude,
        },
      },
      'plantCount': plantCount,
      // El backend guarda la descripcion en cropType (minimo 2 caracteres).
      // En PATCH se permite null para borrarla; en POST se omite.
      if (cropType != null || nullableCropType) 'cropType': cropType,
    };
  }

  DeviceModel _deviceFromBody(Map<String, dynamic> body) {
    final device = body['device'] as Map<String, dynamic>?;
    if (device == null) {
      throw const ServerException('Respuesta de dispositivos invalida');
    }
    return _deviceFromApi(device);
  }

  Uri _uri(String path) => Uri.parse('${AppConstants.apiBaseUrl}$path');

  Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);
    if (token == null || token.isEmpty) {
      throw const ServerException('No hay una sesion activa');
    }

    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeBody(String responseBody) {
    final decoded = json.decode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const ServerException('Respuesta de dispositivos invalida');
    }
    return decoded;
  }

  DeviceModel _deviceFromApi(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? const {};
    final telemetry =
        json['lastTelemetry'] as Map<String, dynamic>? ?? const {};
    final soilMoisture =
        (telemetry['soilMoisturePct'] as num?)?.round() ?? 0;

    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Dispositivo',
      location: location['label'] as String? ?? 'Sin ubicacion',
      status: json['status'] == 'online'
          ? DeviceStatus.online
          : DeviceStatus.offline,
      temperatureC: (telemetry['temperatureC'] as num?)?.toDouble() ?? 0,
      humidityPct: soilMoisture,
      batteryPct: (telemetry['batteryPct'] as num?)?.round() ?? 0,
      plantCount: (json['plantCount'] as num?)?.toInt() ?? 0,
      weather: 'Sin datos',
      avgHumidityPct: soilMoisture,
      latitude: (location['latitude'] as num?)?.toDouble(),
      longitude: (location['longitude'] as num?)?.toDouble(),
      description: json['cropType'] as String?,
    );
  }

  String _errorMessage(Map<String, dynamic> body, String fallback) {
    final message = body['message'];
    return message is String && message.isNotEmpty ? message : fallback;
  }
}
