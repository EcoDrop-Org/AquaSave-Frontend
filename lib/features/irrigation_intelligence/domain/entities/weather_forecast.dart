import 'package:equatable/equatable.dart';

class WeatherForecast extends Equatable {
  final String deviceId;
  final String locationName;
  final double latitude;
  final double longitude;
  final double temperatureC;
  final double apparentTemperatureC;
  final int humidityPct;
  final int rainProbabilityPct;
  final double precipitationMm;
  final double windSpeedKmh;
  final int weatherCode;
  final String conditionLabel;
  final bool isDay;
  final DateTime retrievedAt;
  final DateTime validUntil;

  const WeatherForecast({
    required this.deviceId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.temperatureC,
    required this.apparentTemperatureC,
    required this.humidityPct,
    required this.rainProbabilityPct,
    required this.precipitationMm,
    required this.windSpeedKmh,
    required this.weatherCode,
    required this.conditionLabel,
    required this.isDay,
    required this.retrievedAt,
    required this.validUntil,
  });

  bool get shouldPauseIrrigation =>
      rainProbabilityPct >= 70 || precipitationMm > 0;

  /// true cuando el backend no pudo consultar al proveedor de clima y
  /// respondio un pronostico por defecto (20 C) en lugar de datos reales.
  ///
  /// Hoy se detecta por la etiqueta que envia el backend; lo correcto es que
  /// la API exponga un campo booleano (ver DOCS-BACKEND-PENDIENTE.md).
  bool get isEstimated => conditionLabel.trim().toLowerCase() == 'clima estimado';

  @override
  List<Object?> get props => [
    deviceId,
    locationName,
    latitude,
    longitude,
    temperatureC,
    apparentTemperatureC,
    humidityPct,
    rainProbabilityPct,
    precipitationMm,
    windSpeedKmh,
    weatherCode,
    conditionLabel,
    isDay,
    retrievedAt,
    validUntil,
  ];
}
