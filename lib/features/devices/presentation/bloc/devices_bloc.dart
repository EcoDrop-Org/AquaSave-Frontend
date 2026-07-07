import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/devices_repository.dart';
import '../../domain/usecases/get_devices_usecase.dart';

part 'devices_event.dart';
part 'devices_state.dart';

class DevicesBloc extends Bloc<DevicesEvent, DevicesState> {
  final GetDevicesUseCase getDevicesUseCase;
  final DevicesRepository devicesRepository;
  final List<Device> _devices = [];
  String? _activeDeviceId;
  bool _loaded = false;

  DevicesBloc({required this.getDevicesUseCase, required this.devicesRepository})
    : super(const DevicesInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<AddDeviceRequested>(_onAddDeviceRequested);
    on<DeviceProvisioned>(_onDeviceProvisioned);
    on<EditDeviceRequested>(_onEditDeviceRequested);
    on<DeleteDeviceRequested>(_onDeleteDeviceRequested);
    on<ToggleDevicePause>(_onToggleDevicePause);
    on<SelectActiveDevice>(_onSelectActiveDevice);
    on<ResetDevices>(_onResetDevices);
  }

  Future<void> _onToggleDevicePause(
    ToggleDevicePause event,
    Emitter<DevicesState> emit,
  ) async {
    final index = _devices.indexWhere((device) => device.id == event.deviceId);
    if (index == -1) return;

    final result = await devicesRepository.setDevicePaused(
      event.deviceId,
      event.paused,
    );

    result.fold((failure) => _emitLoaded(emit, error: failure.message), (
      device,
    ) {
      _devices[index] = _devices[index].copyWith(isActive: device.isActive);
      _emitLoaded(emit);
    });
  }

  /// Incorpora un dispositivo creado fuera del bloc (aprovisionamiento del
  /// wizard). Sin esto, el EditDeviceRequested final del wizard no encontraba
  /// el dispositivo en la lista local y descartaba nombre/ubicacion/cultivo.
  void _onDeviceProvisioned(
    DeviceProvisioned event,
    Emitter<DevicesState> emit,
  ) {
    if (_devices.every((device) => device.id != event.device.id)) {
      _devices.add(event.device);
    }
    _activeDeviceId = event.device.id;
    _loaded = true;
    _emitLoaded(emit);
  }

  void _emitLoaded(Emitter<DevicesState> emit, {String? error}) {
    emit(
      DevicesLoaded(
        List.unmodifiable(_devices),
        activeDeviceId: _activeDeviceId,
        lastError: error,
      ),
    );
  }

  Future<void> _onLoadDevices(
    LoadDevices event,
    Emitter<DevicesState> emit,
  ) async {
    if (_loaded) {
      _emitLoaded(emit);
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
      _emitLoaded(emit);
    });
  }

  Future<void> _onAddDeviceRequested(
    AddDeviceRequested event,
    Emitter<DevicesState> emit,
  ) async {
    final result = await devicesRepository.addDevice(
      name: event.name,
      location: event.location,
      plantCount: event.plantCount,
      latitude: event.latitude,
      longitude: event.longitude,
      description: event.description,
    );

    result.fold((failure) => _emitLoaded(emit, error: failure.message), (
      device,
    ) {
      final stored = event.locationByLocale == null
          ? device
          : device.copyWith(locationByLocale: event.locationByLocale);
      _devices.add(stored);
      _activeDeviceId = stored.id;
      _loaded = true;
      _emitLoaded(emit);
    });
  }

  void _onSelectActiveDevice(
    SelectActiveDevice event,
    Emitter<DevicesState> emit,
  ) {
    if (_devices.every((device) => device.id != event.deviceId)) return;

    _activeDeviceId = event.deviceId;
    _emitLoaded(emit);
  }

  Future<void> _onEditDeviceRequested(
    EditDeviceRequested event,
    Emitter<DevicesState> emit,
  ) async {
    final index = _devices.indexWhere((device) => device.id == event.deviceId);
    if (index == -1) return;

    final current = _devices[index];
    final hasNewCoords = event.latitude != null && event.longitude != null;
    final locationChanged = event.location != current.location;
    final keepCurrentCoords = !hasNewCoords && !locationChanged;
    final description =
        event.clearDescription ? null : event.description ?? current.description;

    final result = await devicesRepository.updateDevice(
      deviceId: event.deviceId,
      name: event.name,
      location: event.location,
      plantCount: event.plantCount,
      latitude: hasNewCoords
          ? event.latitude
          : (keepCurrentCoords ? current.latitude : null),
      longitude: hasNewCoords
          ? event.longitude
          : (keepCurrentCoords ? current.longitude : null),
      description: description,
    );

    result.fold((failure) => _emitLoaded(emit, error: failure.message), (_) {
      _devices[index] = current.copyWith(
        name: event.name,
        location: event.location,
        plantCount: event.plantCount,
        latitude: hasNewCoords ? event.latitude : null,
        longitude: hasNewCoords ? event.longitude : null,
        clearCoordinates: !hasNewCoords && locationChanged,
        description: event.description,
        clearDescription: event.clearDescription,
        locationByLocale: event.locationByLocale,
        clearLocationByLocale: event.locationByLocale == null && locationChanged,
      );
      _emitLoaded(emit);
    });
  }

  Future<void> _onDeleteDeviceRequested(
    DeleteDeviceRequested event,
    Emitter<DevicesState> emit,
  ) async {
    final index = _devices.indexWhere((device) => device.id == event.deviceId);
    if (index == -1) return;

    final result = await devicesRepository.deleteDevice(event.deviceId);

    result.fold((failure) => _emitLoaded(emit, error: failure.message), (_) {
      _devices.removeAt(index);
      if (_activeDeviceId == event.deviceId) {
        _activeDeviceId = _devices.isNotEmpty ? _devices.first.id : null;
      }
      _emitLoaded(emit);
    });
  }

  void _onResetDevices(ResetDevices event, Emitter<DevicesState> emit) {
    _devices.clear();
    _activeDeviceId = null;
    _loaded = false;
    emit(const DevicesInitial());
  }
}
