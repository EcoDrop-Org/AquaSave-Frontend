import '../../models/device_model.dart';

abstract class DevicesRemoteDataSource {
  // TODO: GET /api/devices
  Future<List<DeviceModel>> getDevices();
}

class DevicesRemoteDataSourceImpl implements DevicesRemoteDataSource {
  @override
  Future<List<DeviceModel>> getDevices() {
    // TODO: conectar endpoint GET /api/devices
    throw UnimplementedError();
  }
}
