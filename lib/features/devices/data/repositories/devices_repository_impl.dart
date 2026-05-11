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
    }
  }
}
