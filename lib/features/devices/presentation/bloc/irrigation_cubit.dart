import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../data/datasources/remote/irrigation_remote_datasource.dart';

class IrrigationCubit extends Cubit<IrrigationState> {
  /// Cuando es null funciona en modo local (mock); cuando esta presente,
  /// iniciar/detener riego llama a la API del backend.
  final IrrigationRemoteDataSource? remote;
  Timer? _timer;
  Timer? _pollTimer;

  IrrigationCubit({this.remote}) : super(const IrrigationState.initial());

  /// Observa el dispositivo activo: sincroniza ya y luego consulta el estado
  /// del backend periodicamente. Asi, si el riego lo inicia el PROPIO
  /// dispositivo (sensores) o la programacion automatica, la app lo refleja
  /// sin que el usuario tenga que hacer nada.
  void watchDevice(String deviceId) {
    _pollTimer?.cancel();
    syncWithServer(deviceId);
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => syncWithServer(deviceId),
    );
  }

  Future<bool> start(String deviceId) async {
    if (remote != null) {
      try {
        await remote!.start(deviceId);
      } catch (e) {
        _emitError(e, 'No se pudo iniciar el riego');
        return false;
      }
    }

    emit(
      IrrigationState(
        deviceId: deviceId,
        isIrrigating: true,
        startedAt: DateTime.now(),
        elapsedSeconds: 0,
        triggerType: 'manual',
      ),
    );
    _startTicker();
    return true;
  }

  Future<bool> stop() async {
    if (!state.isIrrigating) return true;

    final deviceId = state.deviceId;
    if (remote != null && deviceId != null) {
      try {
        await remote!.stop(deviceId);
      } catch (e) {
        _emitError(e, 'No se pudo detener el riego');
        return false;
      }
    }

    _timer?.cancel();
    emit(state.copyWith(isIrrigating: false));
    return true;
  }

  /// Consulta el estado real del riego en el backend (por ejemplo al cambiar
  /// de dispositivo o reabrir la app) y sincroniza el temporizador.
  Future<void> syncWithServer(String deviceId) async {
    if (remote == null) return;

    try {
      final serverState = await remote!.getState(deviceId);
      if (serverState.isRunning) {
        emit(
          IrrigationState(
            deviceId: deviceId,
            isIrrigating: true,
            startedAt: DateTime.now().subtract(
              Duration(seconds: serverState.elapsedSeconds),
            ),
            elapsedSeconds: serverState.elapsedSeconds,
            // Quien inicio el riego: 'manual' (usuario), 'automatic'
            // (sensores del dispositivo) o 'scheduled' (programacion).
            triggerType: serverState.runningEvent?.triggerType,
          ),
        );
        _startTicker();
      } else if (state.isIrrigating && state.deviceId == deviceId) {
        _timer?.cancel();
        emit(state.copyWith(isIrrigating: false));
      }
    } catch (_) {
      // La sincronizacion es best-effort; no interrumpe la UI.
    }
  }

  void _emitError(Object error, String fallback) {
    final message = error is ServerException
        ? error.message
        : error is AuthException
        ? error.message
        : fallback;
    emit(state.copyWith(errorMessage: message));
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final startedAt = state.startedAt;
    if (!state.isIrrigating || startedAt == null) return;

    emit(
      state.copyWith(
        elapsedSeconds: DateTime.now().difference(startedAt).inSeconds,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _pollTimer?.cancel();
    return super.close();
  }
}

class IrrigationState extends Equatable {
  final String? deviceId;
  final bool isIrrigating;
  final DateTime? startedAt;
  final int elapsedSeconds;

  /// Origen del riego en curso: 'manual', 'automatic' (sensores del
  /// dispositivo) o 'scheduled' (programacion). Null si no se sabe.
  final String? triggerType;

  /// Error de la ultima accion contra la API (null si no hubo error).
  final String? errorMessage;

  const IrrigationState({
    required this.deviceId,
    required this.isIrrigating,
    required this.startedAt,
    required this.elapsedSeconds,
    this.triggerType,
    this.errorMessage,
  });

  const IrrigationState.initial()
    : deviceId = null,
      isIrrigating = false,
      startedAt = null,
      elapsedSeconds = 0,
      triggerType = null,
      errorMessage = null;

  IrrigationState copyWith({
    String? deviceId,
    bool? isIrrigating,
    DateTime? startedAt,
    int? elapsedSeconds,
    String? triggerType,
    String? errorMessage,
  }) {
    return IrrigationState(
      deviceId: deviceId ?? this.deviceId,
      isIrrigating: isIrrigating ?? this.isIrrigating,
      startedAt: startedAt ?? this.startedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      triggerType: triggerType ?? this.triggerType,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    deviceId,
    isIrrigating,
    startedAt,
    elapsedSeconds,
    triggerType,
    errorMessage,
  ];
}
