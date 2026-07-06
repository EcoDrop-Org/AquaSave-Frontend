import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../data/datasources/remote/irrigation_remote_datasource.dart';

class IrrigationCubit extends Cubit<IrrigationState> {
  final IrrigationRemoteDataSource? remote;
  Timer? _timer;
  Timer? _pollTimer;

  IrrigationCubit({this.remote}) : super(const IrrigationState.initial());

  void watchDevice(String deviceId) {
    _pollTimer?.cancel();
    syncWithServer(deviceId);
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
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
        lastAutoStart: state.lastAutoStart,
        lastAutoEnd: state.lastAutoEnd,
        lastManualStart: state.lastManualStart,
        lastManualEnd: state.lastManualEnd,
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
    if (deviceId != null) syncWithServer(deviceId);
    return true;
  }

  Future<void> syncWithServer(String deviceId) async {
    if (remote == null) return;

    try {
      final serverState = await remote!.getState(deviceId);

      DateTime? lastAutoStart = state.lastAutoStart;
      DateTime? lastAutoEnd = state.lastAutoEnd;
      DateTime? lastManualStart = state.lastManualStart;
      DateTime? lastManualEnd = state.lastManualEnd;

      try {
        final events = await remote!.getEvents(deviceId);
        lastAutoStart = null;
        lastAutoEnd = null;
        lastManualStart = null;
        lastManualEnd = null;
        for (final event in events) {
          if (event.endedAt == null || event.status != 'completed') continue;
          if (event.triggerType == 'manual') {
            if (lastManualStart == null ||
                event.startedAt.isAfter(lastManualStart)) {
              lastManualStart = event.startedAt.toLocal();
              lastManualEnd = event.endedAt!.toLocal();
            }
          } else {
            if (lastAutoStart == null ||
                event.startedAt.isAfter(lastAutoStart)) {
              lastAutoStart = event.startedAt.toLocal();
              lastAutoEnd = event.endedAt!.toLocal();
            }
          }
        }
      } catch (_) {}

      if (serverState.isRunning) {
        emit(
          IrrigationState(
            deviceId: deviceId,
            isIrrigating: true,
            startedAt:
                serverState.runningEvent?.startedAt.toLocal() ??
                DateTime.now().subtract(
                  Duration(seconds: serverState.elapsedSeconds),
                ),
            elapsedSeconds: serverState.elapsedSeconds,
            triggerType: serverState.runningEvent?.triggerType,
            lastAutoStart: lastAutoStart,
            lastAutoEnd: lastAutoEnd,
            lastManualStart: lastManualStart,
            lastManualEnd: lastManualEnd,
          ),
        );
        _startTicker();
      } else {
        _timer?.cancel();
        emit(
          IrrigationState(
            deviceId: deviceId,
            isIrrigating: false,
            startedAt: null,
            elapsedSeconds: 0,
            lastAutoStart: lastAutoStart,
            lastAutoEnd: lastAutoEnd,
            lastManualStart: lastManualStart,
            lastManualEnd: lastManualEnd,
          ),
        );
      }
    } catch (_) {}
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
  final String? triggerType;
  final DateTime? lastAutoStart;
  final DateTime? lastAutoEnd;
  final DateTime? lastManualStart;
  final DateTime? lastManualEnd;
  final String? errorMessage;

  const IrrigationState({
    required this.deviceId,
    required this.isIrrigating,
    required this.startedAt,
    required this.elapsedSeconds,
    this.triggerType,
    this.lastAutoStart,
    this.lastAutoEnd,
    this.lastManualStart,
    this.lastManualEnd,
    this.errorMessage,
  });

  const IrrigationState.initial()
    : deviceId = null,
      isIrrigating = false,
      startedAt = null,
      elapsedSeconds = 0,
      triggerType = null,
      lastAutoStart = null,
      lastAutoEnd = null,
      lastManualStart = null,
      lastManualEnd = null,
      errorMessage = null;

  IrrigationState copyWith({
    String? deviceId,
    bool? isIrrigating,
    DateTime? startedAt,
    int? elapsedSeconds,
    String? triggerType,
    DateTime? lastAutoStart,
    DateTime? lastAutoEnd,
    DateTime? lastManualStart,
    DateTime? lastManualEnd,
    String? errorMessage,
  }) {
    return IrrigationState(
      deviceId: deviceId ?? this.deviceId,
      isIrrigating: isIrrigating ?? this.isIrrigating,
      startedAt: startedAt ?? this.startedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      triggerType: triggerType ?? this.triggerType,
      lastAutoStart: lastAutoStart ?? this.lastAutoStart,
      lastAutoEnd: lastAutoEnd ?? this.lastAutoEnd,
      lastManualStart: lastManualStart ?? this.lastManualStart,
      lastManualEnd: lastManualEnd ?? this.lastManualEnd,
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
    lastAutoStart,
    lastAutoEnd,
    lastManualStart,
    lastManualEnd,
    errorMessage,
  ];
}
