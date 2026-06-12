import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';

abstract class IrrigationRemoteDataSource {
  Future<IrrigationStateModel> getState(String deviceId);

  Future<IrrigationEventModel> start(String deviceId);

  Future<IrrigationEventModel> stop(String deviceId);

  Future<List<IrrigationEventModel>> getEvents(String deviceId);
}

class IrrigationRemoteDataSourceImpl implements IrrigationRemoteDataSource {
  final http.Client client;

  IrrigationRemoteDataSourceImpl({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<IrrigationStateModel> getState(String deviceId) async {
    final response = await client.get(
      _uri('/api/irrigation/devices/$deviceId/state'),
      headers: await _authHeaders(),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200) {
      throw ServerException(
        _errorMessage(body, 'No se pudo cargar el estado de riego'),
      );
    }

    final state = body['state'] as Map<String, dynamic>?;
    if (state == null) {
      throw const ServerException('Respuesta de riego invalida');
    }
    return IrrigationStateModel.fromJson(state);
  }

  @override
  Future<IrrigationEventModel> start(String deviceId) {
    return _postEvent(
      path: '/api/irrigation/devices/$deviceId/start',
      fallback: 'No se pudo iniciar el riego',
    );
  }

  @override
  Future<IrrigationEventModel> stop(String deviceId) {
    return _postEvent(
      path: '/api/irrigation/devices/$deviceId/stop',
      fallback: 'No se pudo detener el riego',
    );
  }

  @override
  Future<List<IrrigationEventModel>> getEvents(String deviceId) async {
    final response = await client.get(
      _uri('/api/irrigation/devices/$deviceId/events'),
      headers: await _authHeaders(),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200) {
      throw ServerException(
        _errorMessage(body, 'No se pudo cargar el historial de riego'),
      );
    }

    final events = body['events'] as List<dynamic>? ?? const [];
    return events
        .whereType<Map<String, dynamic>>()
        .map(IrrigationEventModel.fromJson)
        .toList();
  }

  Future<IrrigationEventModel> _postEvent({
    required String path,
    required String fallback,
  }) async {
    final response = await client.post(_uri(path), headers: await _authHeaders());
    final body = _decodeBody(response.body);
    if (response.statusCode != 202) {
      throw ServerException(_errorMessage(body, fallback));
    }

    final event = body['event'] as Map<String, dynamic>?;
    if (event == null) {
      throw const ServerException('Respuesta de riego invalida');
    }
    return IrrigationEventModel.fromJson(event);
  }

  Uri _uri(String path) => Uri.parse('${AppConstants.apiBaseUrl}$path');

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
      throw const ServerException('Respuesta de riego invalida');
    }
    return decoded;
  }

  String _errorMessage(Map<String, dynamic> body, String fallback) {
    final message = body['message'];
    return message is String && message.isNotEmpty ? message : fallback;
  }
}

class IrrigationStateModel {
  final String deviceId;
  final String valveState;
  final bool isRunning;
  final int elapsedSeconds;
  final IrrigationEventModel? runningEvent;

  const IrrigationStateModel({
    required this.deviceId,
    required this.valveState,
    required this.isRunning,
    required this.elapsedSeconds,
    this.runningEvent,
  });

  factory IrrigationStateModel.fromJson(Map<String, dynamic> json) {
    final runningEvent = json['runningEvent'];
    return IrrigationStateModel(
      deviceId: json['deviceId'] as String,
      valveState: json['valveState'] as String,
      isRunning: json['isRunning'] as bool? ?? false,
      elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt() ?? 0,
      runningEvent: runningEvent is Map<String, dynamic>
          ? IrrigationEventModel.fromJson(runningEvent)
          : null,
    );
  }
}

class IrrigationEventModel {
  final String id;
  final String deviceId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double litersConsumed;
  final String triggerType;
  final String status;

  const IrrigationEventModel({
    required this.id,
    required this.deviceId,
    required this.startedAt,
    required this.endedAt,
    required this.litersConsumed,
    required this.triggerType,
    required this.status,
  });

  factory IrrigationEventModel.fromJson(Map<String, dynamic> json) {
    return IrrigationEventModel(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: _parseDate(json['endedAt']),
      litersConsumed: (json['litersConsumed'] as num?)?.toDouble() ?? 0,
      triggerType: json['triggerType'] as String? ?? 'manual',
      status: json['status'] as String? ?? 'completed',
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
