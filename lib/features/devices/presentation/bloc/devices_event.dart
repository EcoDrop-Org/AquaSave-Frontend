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

  const AddDeviceRequested({
    required this.name,
    required this.location,
    required this.plantCount,
  });

  @override
  List<Object> get props => [name, location, plantCount];
}

class SelectActiveDevice extends DevicesEvent {
  final String deviceId;

  const SelectActiveDevice(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}
