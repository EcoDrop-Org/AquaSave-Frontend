import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/device_model.dart';

abstract class DevicesLocalDataSource {
  Future<List<DeviceModel>> getDevices();
}

class DevicesLocalDataSourceImpl implements DevicesLocalDataSource {
  @override
  Future<List<DeviceModel>> getDevices() async {
    try {
      final jsonString = await rootBundle.loadString('assets/mock/devices.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final list = data['devices'] as List<dynamic>;
      return list
          .map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException('No se pudo cargar devices.json');
    }
  }
}
