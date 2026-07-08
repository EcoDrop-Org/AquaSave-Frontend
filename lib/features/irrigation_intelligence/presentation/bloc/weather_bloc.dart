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
      // Si el clima no llega (backend dormido, sin red), se muestra un
      // pronostico estimado de 20 C en lugar de dejar la card en error.
      (failure) => emit(WeatherLoaded(_fallbackForecast(event.device))),
      (forecast) => emit(WeatherLoaded(forecast)),
    );
  }

  WeatherForecast _fallbackForecast(Device device) {
    return WeatherForecast(
      deviceId: device.id,
      locationName: device.location,
      latitude: device.latitude ?? 0,
      longitude: device.longitude ?? 0,
      temperatureC: 20,
      apparentTemperatureC: 20,
      humidityPct: 60,
      rainProbabilityPct: 0,
      precipitationMm: 0,
      windSpeedKmh: 0,
      weatherCode: 0,
      conditionLabel: 'Clima estimado',
      isDay: true,
      retrievedAt: DateTime.now(),
      // Corto para reintentar pronto y recuperar el clima real.
      validUntil: DateTime.now().add(const Duration(minutes: 5)),
    );
  }
}
