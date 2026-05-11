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
