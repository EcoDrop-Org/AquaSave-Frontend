import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/errors/exceptions.dart';

/// Una red WiFi vista por el ESP32 durante el escaneo (`GET /scan`).
class WifiNetwork {
  final String ssid;
  final int rssi; // dBm: mas cercano a 0 = mejor senal
  final bool secure;

  const WifiNetwork({
    required this.ssid,
    required this.rssi,
    required this.secure,
  });

  /// Barras de senal (0-4) a partir del RSSI, para pintar el icono.
  int get bars {
    if (rssi >= -55) return 4;
    if (rssi >= -65) return 3;
    if (rssi >= -75) return 2;
    if (rssi >= -85) return 1;
    return 0;
  }

  factory WifiNetwork.fromJson(Map<String, dynamic> json) => WifiNetwork(
    ssid: (json['ssid'] as String?)?.trim() ?? '',
    rssi: (json['rssi'] as num?)?.toInt() ?? -100,
    secure: json['secure'] as bool? ?? true,
  );
}

/// Identidad del ESP32 en modo aprovisionamiento (`GET /info`).
class Esp32Info {
  final String ap;
  final String mac;
  final String firmware;
  final bool provisioned;
  final String deviceId;

  const Esp32Info({
    required this.ap,
    required this.mac,
    required this.firmware,
    required this.provisioned,
    required this.deviceId,
  });

  factory Esp32Info.fromJson(Map<String, dynamic> json) => Esp32Info(
    ap: json['ap'] as String? ?? '',
    mac: json['mac'] as String? ?? '',
    firmware: json['firmware'] as String? ?? '',
    provisioned: json['provisioned'] as bool? ?? false,
    deviceId: json['deviceId'] as String? ?? '',
  );
}

/// Cliente HTTP del portal de aprovisionamiento del ESP32.
///
/// Cuando el ESP32 no tiene WiFi configurado, crea la red `AquaSave-XXXX` y
/// expone un servidor HTTP en `http://192.168.4.1`. El usuario debe conectar
/// su equipo/telefono a esa red WiFi antes de usar este datasource.
///
/// Limitacion en web: si la app se sirve por HTTPS, el navegador bloqueara las
/// llamadas a `http://192.168.4.1` (mixed content). En web usar la app por
/// HTTP, o bien la version movil/escritorio.
abstract class Esp32ProvisioningDataSource {
  Future<Esp32Info> fetchInfo();
  Future<List<WifiNetwork>> scanNetworks();

  /// Envia SSID + password + deviceId al ESP32. Devuelve la IP local que
  /// obtuvo el dispositivo si la conexion fue exitosa.
  Future<String> connect({
    required String ssid,
    required String password,
    required String deviceId,
  });
}

class Esp32ProvisioningDataSourceImpl implements Esp32ProvisioningDataSource {
  final http.Client client;

  /// IP base del portal del ESP32 en modo AP. Por defecto la de SoftAP.
  final String baseUrl;

  Esp32ProvisioningDataSourceImpl({
    http.Client? client,
    this.baseUrl = 'http://192.168.4.1',
  }) : client = client ?? http.Client();

  static const _timeout = Duration(seconds: 20);

  @override
  Future<Esp32Info> fetchInfo() async {
    final response = await _get('/info');
    final body = _decodeObject(response.body);
    return Esp32Info.fromJson(body);
  }

  @override
  Future<List<WifiNetwork>> scanNetworks() async {
    final response = await _get('/scan');
    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw const ServerException('Respuesta de escaneo invalida');
    }
    final networks = decoded
        .whereType<Map<String, dynamic>>()
        .map(WifiNetwork.fromJson)
        .where((n) => n.ssid.isNotEmpty)
        .toList();

    // Deduplicar por SSID quedandose con la mejor senal, y ordenar.
    final byName = <String, WifiNetwork>{};
    for (final n in networks) {
      final existing = byName[n.ssid];
      if (existing == null || n.rssi > existing.rssi) byName[n.ssid] = n;
    }
    final result = byName.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
    return result;
  }

  @override
  Future<String> connect({
    required String ssid,
    required String password,
    required String deviceId,
  }) async {
    final http.Response response;
    try {
      response = await client
          .post(
            Uri.parse('$baseUrl/connect'),
            headers: const {'Content-Type': 'application/json'},
            body: json.encode({
              'ssid': ssid,
              'password': password,
              'deviceId': deviceId,
            }),
          )
          .timeout(_timeout);
    } catch (e) {
      throw ServerException(_networkHint(e));
    }

    final body = _decodeObject(response.body);
    final ok = body['ok'] as bool? ?? false;
    if (!ok) {
      final err = body['error'] as String?;
      throw ServerException(
        err ?? 'El dispositivo no pudo conectarse a la red WiFi',
      );
    }
    return body['ip'] as String? ?? '';
  }

  Future<http.Response> _get(String path) async {
    try {
      return await client.get(Uri.parse('$baseUrl$path')).timeout(_timeout);
    } catch (e) {
      throw ServerException(_networkHint(e));
    }
  }

  Map<String, dynamic> _decodeObject(String responseBody) {
    final decoded = json.decode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const ServerException('Respuesta del dispositivo invalida');
    }
    return decoded;
  }

  /// Mensaje util cuando no se alcanza el ESP32 (causa mas comun: no se esta
  /// conectado a la red AquaSave-XXXX, o bloqueo mixed-content en web HTTPS).
  String _networkHint(Object e) =>
      'No se pudo contactar al dispositivo en $baseUrl. '
      'Verifica que tu equipo este conectado a la red WiFi "AquaSave-XXXX". '
      '(detalle: $e)';
}
