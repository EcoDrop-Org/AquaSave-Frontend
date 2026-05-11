import '../../domain/entities/device.dart';

class DeviceModel extends Device {
  const DeviceModel({
    required super.id,
    required super.name,
    required super.location,
    required super.status,
    required super.temperatureC,
    required super.humidityPct,
    required super.batteryPct,
    required super.plantCount,
    required super.weather,
    required super.avgHumidityPct,
    super.latitude,
    super.longitude,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      status: (json['status'] as String) == 'online'
          ? DeviceStatus.online
          : DeviceStatus.offline,
      temperatureC: (json['temperature_c'] as num).toDouble(),
      humidityPct: json['humidity_pct'] as int,
      batteryPct: json['battery_pct'] as int,
      plantCount: json['plant_count'] as int,
      weather: json['weather'] as String,
      avgHumidityPct: json['avg_humidity_pct'] as int,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'status': status == DeviceStatus.online ? 'online' : 'offline',
    'temperature_c': temperatureC,
    'humidity_pct': humidityPct,
    'battery_pct': batteryPct,
    'plant_count': plantCount,
    'weather': weather,
    'avg_humidity_pct': avgHumidityPct,
    'latitude': latitude,
    'longitude': longitude,
  };
}
