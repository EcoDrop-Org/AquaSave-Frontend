import '../../domain/entities/plant_recommendation.dart';

class PlantRecommendationModel extends PlantRecommendation {
  const PlantRecommendationModel({
    required super.deviceId,
    required super.speciesId,
    required super.speciesName,
    required super.irrigation,
    required super.careTips,
    required super.careSource,
    required super.validUntil,
    super.description,
    super.imageUrl,
  });

  factory PlantRecommendationModel.fromJson(Map<String, dynamic> json) {
    final irrigation = json['irrigation'] as Map<String, dynamic>? ?? const {};
    final care = json['care'] as Map<String, dynamic>? ?? const {};
    final info = json['info'] as Map<String, dynamic>?;
    final rawTips = care['tips'];

    return PlantRecommendationModel(
      deviceId: json['deviceId'] as String? ?? '',
      speciesId: json['speciesId'] as String? ?? 'otra',
      speciesName: json['speciesName'] as String? ?? 'Planta',
      irrigation: IrrigationAdvice(
        level: _levelFromApi(irrigation['level'] as String?),
        title: irrigation['title'] as String? ?? 'Recomendación de riego',
        body: irrigation['body'] as String? ?? '',
        reason: irrigation['reason'] as String? ?? '',
        source: _sourceFromApi(irrigation['source'] as String?),
      ),
      careTips: rawTips is List
          ? rawTips
                .whereType<Map<String, dynamic>>()
                .map(
                  (tip) => CareTip(
                    icon: tip['icon'] as String? ?? 'leaf',
                    title: tip['title'] as String? ?? '',
                    body: tip['body'] as String? ?? '',
                  ),
                )
                .where((tip) => tip.body.isNotEmpty)
                .toList()
          : const [],
      careSource: _sourceFromApi(care['source'] as String?),
      description: _nonEmpty(info?['description'] as String?),
      imageUrl: _nonEmpty(info?['imageUrl'] as String?),
      validUntil:
          DateTime.tryParse(json['validUntil'] as String? ?? '') ??
          DateTime.now().add(const Duration(minutes: 10)),
    );
  }

  static RecommendationLevel _levelFromApi(String? raw) {
    return switch (raw) {
      'act' => RecommendationLevel.act,
      'watch' => RecommendationLevel.watch,
      _ => RecommendationLevel.ok,
    };
  }

  static AdviceSource _sourceFromApi(String? raw) {
    return raw == 'ai' ? AdviceSource.ai : AdviceSource.rules;
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
