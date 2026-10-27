import 'package:equatable/equatable.dart';

/// Planta que el usuario puede elegir con un botón en el chat.
class ChatPlantOption extends Equatable {
  final String deviceId;
  final String name;
  final String speciesName;
  final int? soilMoisturePct;
  final bool hasIrrigationDevice;

  const ChatPlantOption({
    required this.deviceId,
    required this.name,
    required this.speciesName,
    required this.hasIrrigationDevice,
    this.soilMoisturePct,
  });

  factory ChatPlantOption.fromJson(Map<String, dynamic> json) {
    return ChatPlantOption(
      deviceId: json['deviceId'] as String? ?? '',
      name: json['name'] as String? ?? 'Planta',
      speciesName: json['speciesName'] as String? ?? '',
      hasIrrigationDevice: json['hasIrrigationDevice'] as bool? ?? false,
      soilMoisturePct: (json['soilMoisturePct'] as num?)?.round(),
    );
  }

  @override
  List<Object?> get props => [deviceId, name, soilMoisturePct];
}

/// Mensaje del chat. `options` solo viene en respuestas del asistente.
class ChatMessage extends Equatable {
  final String text;
  final bool isUser;

  /// true cuando el texto lo redactó la IA (y no el motor de reglas).
  final bool fromAi;
  final List<ChatPlantOption> options;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.fromAi = false,
    this.options = const [],
  });

  @override
  List<Object?> get props => [text, isUser, fromAi, options];
}
