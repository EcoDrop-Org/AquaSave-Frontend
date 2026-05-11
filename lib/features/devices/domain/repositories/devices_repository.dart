import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/device.dart';

abstract class DevicesRepository {
  Future<Either<Failure, List<Device>>> getDevices();
}
