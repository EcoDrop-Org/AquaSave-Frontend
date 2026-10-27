import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/plant_recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';

sealed class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object?> get props => [];
}

class RecommendationInitial extends RecommendationState {
  const RecommendationInitial();
}

class RecommendationLoading extends RecommendationState {
  final String deviceId;

  const RecommendationLoading(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class RecommendationLoaded extends RecommendationState {
  final PlantRecommendation recommendation;

  const RecommendationLoaded(this.recommendation);

  @override
  List<Object?> get props => [recommendation];
}

/// La recomendación no se pudo cargar. La app sigue funcionando: las tarjetas
/// que dependen de ella simplemente no se muestran.
class RecommendationFailure extends RecommendationState {
  final String message;

  const RecommendationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class RecommendationCubit extends Cubit<RecommendationState> {
  final RecommendationRepository repository;

  RecommendationCubit({required this.repository})
    : super(const RecommendationInitial());

  Future<void> load(String deviceId, {bool force = false}) async {
    final current = state;

    // El backend ya cachea 10 min; no vale la pena pedirla de nuevo mientras
    // siga vigente y sea la misma planta.
    if (!force &&
        current is RecommendationLoaded &&
        current.recommendation.deviceId == deviceId &&
        !current.recommendation.isExpired) {
      return;
    }

    emit(RecommendationLoading(deviceId));
    final result = await repository.getRecommendation(deviceId);
    if (isClosed) return;

    result.fold(
      (failure) => emit(RecommendationFailure(failure.message)),
      (recommendation) => emit(RecommendationLoaded(recommendation)),
    );
  }
}
