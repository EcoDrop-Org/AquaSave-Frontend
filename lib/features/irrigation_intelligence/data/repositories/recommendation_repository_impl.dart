import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/plant_recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/remote/recommendation_remote_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDataSource remoteDataSource;

  const RecommendationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PlantRecommendation>> getRecommendation(
    String deviceId,
  ) async {
    try {
      final recommendation = await remoteDataSource.getRecommendation(deviceId);
      return Right(recommendation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FormatException {
      return const Left(ServerFailure('Respuesta de recomendación invalida'));
    } on http.ClientException {
      return const Left(NetworkFailure('No se pudo conectar con el servidor'));
    } catch (_) {
      return const Left(
        ServerFailure('No se pudo cargar la recomendación'),
      );
    }
  }
}
