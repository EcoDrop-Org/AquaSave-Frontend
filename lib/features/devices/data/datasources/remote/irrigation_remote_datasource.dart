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

  Future<AnalyticsModel> getAnalytics(String? deviceId);

  Future<Map<String, dynamic>> getDeviceSettings(String deviceId);

  Future<Map<String, dynamic>> putDeviceSettings(
    String deviceId,
    Map<String, dynamic> settings,
  );
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

  @override
  Future<AnalyticsModel> getAnalytics(String? deviceId) async {
    final queryParam = deviceId != null ? '?deviceId=$deviceId' : '';
    final response = await client.get(
      _uri('/api/irrigation/analytics$queryParam'),
      headers: await _authHeaders(),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200) {
      throw ServerException(
        _errorMessage(body, 'No se pudo cargar los analíticos'),
      );
    }
    return AnalyticsModel.fromJson(body);
  }

  @override
  Future<Map<String, dynamic>> getDeviceSettings(String deviceId) async {
    final response = await client.get(
      _uri('/api/devices/$deviceId/settings'),
      headers: await _authHeaders(),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200) {
      throw ServerException(
        _errorMessage(body, 'No se pudo cargar la configuración'),
      );
    }
    // Backend devuelve { settings: { ... } } — desempaquetar
    final inner = body['settings'];
    if (inner is Map<String, dynamic>) return inner;
    return body;
  }

  @override
  Future<Map<String, dynamic>> putDeviceSettings(
    String deviceId,
    Map<String, dynamic> settings,
  ) async {
    final response = await client.put(
      _uri('/api/devices/$deviceId/settings'),
      headers: {
        ...await _authHeaders(),
        'Content-Type': 'application/json',
      },
      body: json.encode(settings),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200) {
      throw ServerException(
        _errorMessage(body, 'No se pudo guardar la configuración'),
      );
    }
    return body;
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

class AnalyticsKpis {
  final double totalLiters;
  final double avgDailyLiters;
  final int totalEvents;
  final double avgDurationMin;

  const AnalyticsKpis({
    required this.totalLiters,
    required this.avgDailyLiters,
    required this.totalEvents,
    required this.avgDurationMin,
  });

  factory AnalyticsKpis.fromJson(Map<String, dynamic> json) {
    return AnalyticsKpis(
      totalLiters: (json['totalLiters'] as num?)?.toDouble() ?? 0,
      avgDailyLiters: (json['avgDailyLiters'] as num?)?.toDouble() ?? 0,
      totalEvents: (json['totalEvents'] as num?)?.toInt() ?? 0,
      avgDurationMin: (json['avgDurationMin'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CropBreakdownItem {
  final String crop;
  final double liters;
  const CropBreakdownItem({required this.crop, required this.liters});

  factory CropBreakdownItem.fromJson(Map<String, dynamic> json) {
    return CropBreakdownItem(
      crop: json['crop'] as String? ?? 'Otro',
      liters: (json['liters'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AnalyticsModel {
  final AnalyticsKpis kpis;
  final List<String> dailyLabels;
  final List<double> dailyValues;
  final List<double> cumulative;
  final List<CropBreakdownItem> cropBreakdown;

  const AnalyticsModel({
    required this.kpis,
    required this.dailyLabels,
    required this.dailyValues,
    required this.cumulative,
    required this.cropBreakdown,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'] as Map<String, dynamic>? ?? {};
    final labels = (daily['labels'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final values = (daily['values'] as List<dynamic>? ?? [])
        .map((e) => (e as num).toDouble())
        .toList();
    final cumulative = (json['cumulative'] as List<dynamic>? ?? [])
        .map((e) => (e as num).toDouble())
        .toList();
    final crops = (json['cropBreakdown'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CropBreakdownItem.fromJson)
        .toList();

    return AnalyticsModel(
      kpis: AnalyticsKpis.fromJson(
        json['kpis'] as Map<String, dynamic>? ?? {},
      ),
      dailyLabels: labels,
      dailyValues: values,
      cumulative: cumulative,
      cropBreakdown: crops,
    );
  }
}
