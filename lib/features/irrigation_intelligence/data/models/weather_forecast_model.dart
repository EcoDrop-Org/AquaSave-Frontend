import '../../domain/entities/weather_forecast.dart';

class WeatherForecastModel extends WeatherForecast {
  const WeatherForecastModel({
    required super.deviceId,
    required super.locationName,
    required super.latitude,
    required super.longitude,
    required super.temperatureC,
    required super.apparentTemperatureC,
    required super.humidityPct,
    required super.rainProbabilityPct,
    required super.precipitationMm,
    required super.windSpeedKmh,
    required super.weatherCode,
    required super.conditionLabel,
    required super.isDay,
    required super.retrievedAt,
    required super.validUntil,
  });

  factory WeatherForecastModel.fromOpenMeteo({
    required String deviceId,
    required String locationName,
    required double requestedLatitude,
    required double requestedLongitude,
    required Map<String, dynamic> json,
  }) {
    final current = json['current'] as Map<String, dynamic>? ?? const {};
    final daily = json['daily'] as Map<String, dynamic>? ?? const {};
    final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
    final retrievedAt = DateTime.now();

    final rainProbabilities =
        daily['precipitation_probability_max'] as List<dynamic>? ?? const [];
    final rainProbability = rainProbabilities.isNotEmpty
        ? (rainProbabilities.first as num?)?.toInt() ?? 0
        : 0;

    return WeatherForecastModel(
      deviceId: deviceId,
      locationName: locationName,
      latitude: (json['latitude'] as num?)?.toDouble() ?? requestedLatitude,
      longitude: (json['longitude'] as num?)?.toDouble() ?? requestedLongitude,
      temperatureC: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      apparentTemperatureC:
          (current['apparent_temperature'] as num?)?.toDouble() ?? 0,
      humidityPct: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      rainProbabilityPct: rainProbability,
      precipitationMm: (current['precipitation'] as num?)?.toDouble() ?? 0,
      windSpeedKmh: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      weatherCode: weatherCode,
      conditionLabel: _conditionLabel(weatherCode),
      isDay: ((current['is_day'] as num?)?.toInt() ?? 1) == 1,
      retrievedAt: retrievedAt,
      validUntil: retrievedAt.add(const Duration(minutes: 30)),
    );
  }

  static String _conditionLabel(int code) {
    if (code == 0) return 'Despejado';
    if ([1, 2, 3].contains(code)) return 'Parcialmente nublado';
    if ([45, 48].contains(code)) return 'Neblina';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Llovizna';
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Lluvia';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Nieve';
    if ([95, 96, 99].contains(code)) return 'Tormenta';
    return 'Clima variable';
  }
}
