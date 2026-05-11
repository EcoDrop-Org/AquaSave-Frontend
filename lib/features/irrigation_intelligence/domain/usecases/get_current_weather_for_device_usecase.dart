import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../devices/domain/entities/device.dart';
import '../entities/weather_forecast.dart';
import '../repositories/weather_repository.dart';

class GetCurrentWeatherForDeviceUseCase
    implements UseCase<WeatherForecast, Device> {
  final WeatherRepository repository;

  const GetCurrentWeatherForDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, WeatherForecast>> call(Device params) {
    return repository.getCurrentWeatherForDevice(params);
  }
}
