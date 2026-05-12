import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IrrigationCubit extends Cubit<IrrigationState> {
  Timer? _timer;

  IrrigationCubit() : super(const IrrigationState.initial());

  void start(String deviceId) {
    final startedAt = DateTime.now();
    emit(
      IrrigationState(
        deviceId: deviceId,
        isIrrigating: true,
        startedAt: startedAt,
        elapsedSeconds: 0,
      ),
    );
    _startTicker();
  }

  void stop() {
    if (!state.isIrrigating) return;

    _timer?.cancel();
    emit(state.copyWith(isIrrigating: false));
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
    return super.close();
  }
}

class IrrigationState extends Equatable {
  final String? deviceId;
  final bool isIrrigating;
  final DateTime? startedAt;
  final int elapsedSeconds;

  const IrrigationState({
    required this.deviceId,
    required this.isIrrigating,
    required this.startedAt,
    required this.elapsedSeconds,
  });

  const IrrigationState.initial()
    : deviceId = null,
      isIrrigating = false,
      startedAt = null,
      elapsedSeconds = 0;

  IrrigationState copyWith({
    String? deviceId,
    bool? isIrrigating,
    DateTime? startedAt,
    int? elapsedSeconds,
  }) {
    return IrrigationState(
      deviceId: deviceId ?? this.deviceId,
      isIrrigating: isIrrigating ?? this.isIrrigating,
      startedAt: startedAt ?? this.startedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  @override
  List<Object?> get props => [
    deviceId,
    isIrrigating,
    startedAt,
    elapsedSeconds,
  ];
}
