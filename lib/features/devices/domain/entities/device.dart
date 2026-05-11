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
  });

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
  ];
}
