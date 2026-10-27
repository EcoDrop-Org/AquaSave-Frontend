import 'package:equatable/equatable.dart';

/// Urgencia de la recomendación de riego.
enum RecommendationLevel { ok, watch, act }

/// Quién redactó el texto: el motor de reglas o la IA.
enum AdviceSource { rules, ai }

/// Recomendación de riego: qué hacer ahora con el agua.
///
/// `level` y `reason` siempre vienen del motor de reglas del backend; la IA
/// solo reescribe `body`, nunca cambia el diagnóstico.
class IrrigationAdvice extends Equatable {
  final RecommendationLevel level;
  final String title;
  final String body;

  /// Los datos que llevaron a esa conclusión (se muestra al experto).
  final String reason;
  final AdviceSource source;

  const IrrigationAdvice({
    required this.level,
    required this.title,
    required this.body,
    required this.reason,
    required this.source,
  });

  @override
  List<Object?> get props => [level, title, body, reason, source];
}

/// Consejo de cuidado de la especie.
class CareTip extends Equatable {
  /// Uno de: sun, water, bug, leaf.
  final String icon;
  final String title;
  final String body;

  const CareTip({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [icon, title, body];
}

/// Recomendación completa de una planta.
///
/// Los `careTips` no dependen del sensor, así que sirven aunque la planta
/// todavía no tenga un dispositivo de riego vinculado.
class PlantRecommendation extends Equatable {
  final String deviceId;
  final String speciesId;
  final String speciesName;
  final IrrigationAdvice irrigation;
  final List<CareTip> careTips;
  final AdviceSource careSource;

  /// Ficha de la especie. Puede faltar si el proveedor externo no respondió.
  final String? description;
  final String? imageUrl;
  final DateTime validUntil;

  const PlantRecommendation({
    required this.deviceId,
    required this.speciesId,
    required this.speciesName,
    required this.irrigation,
    required this.careTips,
    required this.careSource,
    required this.validUntil,
    this.description,
    this.imageUrl,
  });

  bool get isExpired => DateTime.now().isAfter(validUntil);

  @override
  List<Object?> get props => [
    deviceId,
    speciesId,
    speciesName,
    irrigation,
    careTips,
    careSource,
    description,
    imageUrl,
    validUntil,
  ];
}
