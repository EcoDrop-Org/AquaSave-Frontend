import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/devices_repository.dart';
import '../datasources/local/devices_local_datasource.dart';
import '../datasources/remote/devices_remote_datasource.dart';

class DevicesRepositoryImpl implements DevicesRepository {
  final DevicesLocalDataSource localDataSource;
  final DevicesRemoteDataSource remoteDataSource;
  final bool useMock;

  const DevicesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.useMock,
  });

  @override
  Future<Either<Failure, List<Device>>> getDevices() async {
    try {
      final result = useMock
          ? await localDataSource.getDevices()
          : await remoteDataSource.getDevices();
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('No se pudo conectar con el servidor'));
    }
  }

  @override
  Future<Either<Failure, Device>> addDevice({
    required String name,
    required String location,
    required int plantCount,
    double? latitude,
    double? longitude,
    String? description,
  }) async {
    if (useMock) {
      return Right(
        Device(
          id: 'd${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          location: location,
          status: DeviceStatus.online,
          temperatureC: 24,
          humidityPct: 50,
          batteryPct: 100,
          plantCount: plantCount,
          weather: 'Buscando clima',
          avgHumidityPct: 50,
          latitude: latitude,
          longitude: longitude,
          description: description,
        ),
      );
    }

    try {
      final device = await remoteDataSource.addDevice(
        name: name,
        location: location,
        plantCount: plantCount,
        latitude: latitude,
        longitude: longitude,
        description: description,
      );
      return Right(device);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('No se pudo conectar con el servidor'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateDevice({
    required String deviceId,
    required String name,
    required String location,
    required int plantCount,
    double? latitude,
    double? longitude,
    String? description,
  }) async {
    if (useMock) return const Right(unit);

    try {
      await remoteDataSource.updateDevice(
        deviceId: deviceId,
        name: name,
        location: location,
        plantCount: plantCount,
        latitude: latitude,
        longitude: longitude,
        description: description,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('No se pudo conectar con el servidor'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDevice(String deviceId) async {
    if (useMock) return const Right(unit);

    try {
      await remoteDataSource.deleteDevice(deviceId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('No se pudo conectar con el servidor'));
    }
  }
}
