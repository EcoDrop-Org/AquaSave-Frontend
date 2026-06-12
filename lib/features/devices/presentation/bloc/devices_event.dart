part of 'devices_bloc.dart';

abstract class DevicesEvent extends Equatable {
  const DevicesEvent();
  @override
  List<Object> get props => [];
}

class LoadDevices extends DevicesEvent {
  const LoadDevices();
}

class AddDeviceRequested extends DevicesEvent {
  final String name;
  final String location;
  final int plantCount;
  final double? latitude;
  final double? longitude;
  final String? description;
  final Map<String, String>? locationByLocale;

  const AddDeviceRequested({
    required this.name,
    required this.location,
    required this.plantCount,
    this.latitude,
    this.longitude,
    this.description,
    this.locationByLocale,
  });

  @override
  List<Object> get props => [name, location, plantCount];
}

class EditDeviceRequested extends DevicesEvent {
  final String deviceId;
  final String name;
  final String location;
  final int plantCount;
  final double? latitude;
  final double? longitude;
  final String? description;
  final bool clearDescription;
  final Map<String, String>? locationByLocale;

  const EditDeviceRequested({
    required this.deviceId,
    required this.name,
    required this.location,
    required this.plantCount,
    this.latitude,
    this.longitude,
    this.description,
    this.clearDescription = false,
    this.locationByLocale,
  });

  @override
  List<Object> get props => [deviceId, name, location, plantCount];
}

class DeleteDeviceRequested extends DevicesEvent {
  final String deviceId;

  const DeleteDeviceRequested(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class ResetDevices extends DevicesEvent {
  const ResetDevices();
}

class SelectActiveDevice extends DevicesEvent {
  final String deviceId;

  const SelectActiveDevice(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}
