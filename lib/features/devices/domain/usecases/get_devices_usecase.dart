import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/device.dart';
import '../repositories/devices_repository.dart';

class GetDevicesUseCase implements UseCase<List<Device>, NoParams> {
  final DevicesRepository repository;

  const GetDevicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Device>>> call(NoParams params) {
    return repository.getDevices();
  }
}
