import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../devices/domain/entities/device.dart';
import '../../domain/entities/weather_forecast.dart';
import '../../domain/usecases/get_current_weather_for_device_usecase.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetCurrentWeatherForDeviceUseCase getCurrentWeatherForDeviceUseCase;

  WeatherBloc({required this.getCurrentWeatherForDeviceUseCase})
    : super(const WeatherInitial()) {
    on<LoadWeatherForDevice>(_onLoadWeatherForDevice);
  }

  Future<void> _onLoadWeatherForDevice(
    LoadWeatherForDevice event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading(event.device.id));
    final result = await getCurrentWeatherForDeviceUseCase(event.device);
    result.fold(
      (failure) => emit(WeatherFailureState(event.device.id, failure.message)),
      (forecast) => emit(WeatherLoaded(forecast)),
    );
  }
}
