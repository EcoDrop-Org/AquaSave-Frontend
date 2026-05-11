import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/device.dart';
import '../../domain/usecases/get_devices_usecase.dart';

part 'devices_event.dart';
part 'devices_state.dart';

class DevicesBloc extends Bloc<DevicesEvent, DevicesState> {
  final GetDevicesUseCase getDevicesUseCase;

  DevicesBloc({required this.getDevicesUseCase}) : super(const DevicesInitial()) {
    on<LoadDevices>(_onLoadDevices);
  }

  Future<void> _onLoadDevices(
    LoadDevices event,
    Emitter<DevicesState> emit,
  ) async {
    emit(const DevicesLoading());
    final result = await getDevicesUseCase(const NoParams());
    result.fold(
      (failure) => emit(DevicesFailureState(failure.message)),
      (devices) => emit(DevicesLoaded(devices)),
    );
  }
}
