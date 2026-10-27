import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/plant_recommendation.dart';

abstract class RecommendationRepository {
  Future<Either<Failure, PlantRecommendation>> getRecommendation(
    String deviceId,
  );
}
