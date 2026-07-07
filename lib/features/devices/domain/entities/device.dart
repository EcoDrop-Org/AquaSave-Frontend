import 'package:equatable/equatable.dart';

enum DeviceStatus { online, offline }

class Device extends Equatable {
  final String id;
  final String name;
  final String location;
  final DeviceStatus status;
  final double temperatureC;
  final int humidityPct;
  final int batteryPct;
  final int plantCount;
  final String weather;
  final int avgHumidityPct;
  final double? latitude;
  final double? longitude;
  final String? description;
  // Versiones localizadas del nombre de ubicación, ej. {'es': 'Alaska,
  // Estados Unidos de América', 'en': 'Alaska, United States'}. Si falta el
  // idioma activo, se cae a `location`.
  final Map<String, String>? locationByLocale;

  // false cuando el usuario pausó el dispositivo remotamente (no riega hasta
  // reactivarlo).
  final bool isActive;

  const Device({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.temperatureC,
    required this.humidityPct,
    required this.batteryPct,
    required this.plantCount,
    required this.weather,
    required this.avgHumidityPct,
    this.latitude,
    this.longitude,
    this.description,
    this.locationByLocale,
    this.isActive = true,
  });

  /// Devuelve el nombre de ubicación adecuado para el idioma activo, con
  /// fallback al string canónico.
  String localizedLocation(String languageCode) {
    final value = locationByLocale?[languageCode];
    if (value != null && value.trim().isNotEmpty) return value;
    return location;
  }

  Device copyWith({
    String? id,
    String? name,
    String? location,
    DeviceStatus? status,
    double? temperatureC,
    int? humidityPct,
    int? batteryPct,
    int? plantCount,
    String? weather,
    int? avgHumidityPct,
    double? latitude,
    double? longitude,
    String? description,
    Map<String, String>? locationByLocale,
    bool? isActive,
    bool clearCoordinates = false,
    bool clearDescription = false,
    bool clearLocationByLocale = false,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
      temperatureC: temperatureC ?? this.temperatureC,
      humidityPct: humidityPct ?? this.humidityPct,
      batteryPct: batteryPct ?? this.batteryPct,
      plantCount: plantCount ?? this.plantCount,
      weather: weather ?? this.weather,
      avgHumidityPct: avgHumidityPct ?? this.avgHumidityPct,
      latitude: clearCoordinates ? null : latitude ?? this.latitude,
      longitude: clearCoordinates ? null : longitude ?? this.longitude,
      description: clearDescription ? null : description ?? this.description,
      locationByLocale: clearLocationByLocale
          ? null
          : locationByLocale ?? this.locationByLocale,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    status,
    temperatureC,
    humidityPct,
    batteryPct,
    plantCount,
    weather,
    avgHumidityPct,
    latitude,
    longitude,
    description,
    locationByLocale,
    isActive,
  ];
}
