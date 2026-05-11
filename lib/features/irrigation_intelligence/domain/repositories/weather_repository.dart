import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../devices/domain/entities/device.dart';
import '../entities/weather_forecast.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherForecast>> getCurrentWeatherForDevice(
    Device device,
  );
}
