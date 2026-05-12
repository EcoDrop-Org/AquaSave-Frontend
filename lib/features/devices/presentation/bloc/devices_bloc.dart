import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/device.dart';
import '../../domain/usecases/get_devices_usecase.dart';

part 'devices_event.dart';
part 'devices_state.dart';

class DevicesBloc extends Bloc<DevicesEvent, DevicesState> {
  final GetDevicesUseCase getDevicesUseCase;
  final List<Device> _devices = [];
  String? _activeDeviceId;
  bool _loaded = false;

  DevicesBloc({required this.getDevicesUseCase})
    : super(const DevicesInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<AddDeviceRequested>(_onAddDeviceRequested);
    on<EditDeviceRequested>(_onEditDeviceRequested);
    on<SelectActiveDevice>(_onSelectActiveDevice);
  }

  Future<void> _onLoadDevices(
    LoadDevices event,
    Emitter<DevicesState> emit,
  ) async {
    if (_loaded) {
      emit(
        DevicesLoaded(
          List.unmodifiable(_devices),
          activeDeviceId: _activeDeviceId,
        ),
      );
      return;
    }

    emit(const DevicesLoading());
    final result = await getDevicesUseCase(const NoParams());
    result.fold((failure) => emit(DevicesFailureState(failure.message)), (
      devices,
    ) {
      _devices
        ..clear()
        ..addAll(devices);
      _activeDeviceId = devices.isNotEmpty ? devices.first.id : null;
      _loaded = true;
      emit(
        DevicesLoaded(
          List.unmodifiable(_devices),
          activeDeviceId: _activeDeviceId,
        ),
      );
    });
  }

  void _onAddDeviceRequested(
    AddDeviceRequested event,
    Emitter<DevicesState> emit,
  ) {
    final device = Device(
      id: 'd${DateTime.now().millisecondsSinceEpoch}',
      name: event.name,
      location: event.location,
      status: DeviceStatus.online,
      temperatureC: 24,
      humidityPct: 50,
      batteryPct: 100,
      plantCount: event.plantCount,
      weather: 'Buscando clima',
      avgHumidityPct: 50,
    );

    _devices.add(device);
    _activeDeviceId = device.id;
    _loaded = true;

    emit(
      DevicesLoaded(
        List.unmodifiable(_devices),
        activeDeviceId: _activeDeviceId,
      ),
    );
  }

  void _onSelectActiveDevice(
    SelectActiveDevice event,
    Emitter<DevicesState> emit,
  ) {
    if (_devices.every((device) => device.id != event.deviceId)) return;

    _activeDeviceId = event.deviceId;
    emit(
      DevicesLoaded(
        List.unmodifiable(_devices),
        activeDeviceId: _activeDeviceId,
      ),
    );
  }

  void _onEditDeviceRequested(
    EditDeviceRequested event,
    Emitter<DevicesState> emit,
  ) {
    final index = _devices.indexWhere((device) => device.id == event.deviceId);
    if (index == -1) return;

    final current = _devices[index];
    _devices[index] = current.copyWith(
      name: event.name,
      location: event.location,
      plantCount: event.plantCount,
      clearCoordinates: event.location != current.location,
    );

    emit(
      DevicesLoaded(
        List.unmodifiable(_devices),
        activeDeviceId: _activeDeviceId,
      ),
    );
  }
}
