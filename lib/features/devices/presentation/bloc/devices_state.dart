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
  const DevicesLoaded(this.devices);
  @override
  List<Object?> get props => [devices];
}

class DevicesFailureState extends DevicesState {
  final String message;
  const DevicesFailureState(this.message);
  @override
  List<Object?> get props => [message];
}
