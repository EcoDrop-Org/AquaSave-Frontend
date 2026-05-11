import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../devices/domain/entities/device.dart';
import '../../domain/entities/weather_forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/remote/weather_remote_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  const WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WeatherForecast>> getCurrentWeatherForDevice(
    Device device,
  ) async {
    try {
      final forecast = await remoteDataSource.getCurrentWeather(
        deviceId: device.id,
        location: device.location,
        latitude: device.latitude,
        longitude: device.longitude,
      );
      return Right(forecast);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FormatException {
      return const Left(ServerFailure('Respuesta de clima invalida'));
    } on http.ClientException {
      return const Left(NetworkFailure('No se pudo conectar con el clima'));
    } catch (_) {
      return const Left(ServerFailure('No se pudo cargar el clima del huerto'));
    }
  }
}
