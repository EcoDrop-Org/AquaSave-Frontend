part of 'devices_bloc.dart';

abstract class DevicesState extends Equatable {
  const DevicesState();
  @override
  List<Object?> get props => [];
}

class DevicesInitial extends DevicesState {
  const DevicesInitial();
}

class DevicesLoading extends DevicesState {
  const DevicesLoading();
}

class DevicesLoaded extends DevicesState {
  final List<Device> devices;
  final String? activeDeviceId;

  const DevicesLoaded(this.devices, {this.activeDeviceId});

  Device get activeDevice {
    return devices.firstWhere(
      (device) => device.id == activeDeviceId,
      orElse: () => devices.first,
    );
  }

  @override
  List<Object?> get props => [devices, activeDeviceId];
}

class DevicesFailureState extends DevicesState {
  final String message;
  const DevicesFailureState(this.message);
  @override
  List<Object?> get props => [message];
}
