import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/device.dart';

abstract class DevicesRepository {
  Future<Either<Failure, List<Device>>> getDevices();

  Future<Either<Failure, Device>> addDevice({
    required String name,
    required String location,
    required int plantCount,
    double? latitude,
    double? longitude,
    String? description,
  });

  Future<Either<Failure, Unit>> updateDevice({
    required String deviceId,
    required String name,
    required String location,
    required int plantCount,
    double? latitude,
    double? longitude,
    String? description,
  });

  Future<Either<Failure, Unit>> deleteDevice(String deviceId);
}
