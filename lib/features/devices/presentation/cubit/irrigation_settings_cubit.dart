import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Reglas que el usuario configura en la pantalla de ajustes y que el resto
/// de la app consume (clima, control rápido, notificaciones, etc.) para
/// decidir qué consejo mostrar.
class IrrigationSettings extends Equatable {
  /// Por debajo de este % de humedad del sustrato, AquaSave avisará y/o regará.
  final double minMoisture;

  /// Rango "ideal" sugerido al usuario.
  final double optimalMoisture;

  /// Por encima de este % de humedad ya no conviene regar.
  final double maxMoisture;

  /// Temperatura desde la que se considera "calor alto" y se recomienda revisar
  /// el riego.
  final double hotAlertC;

  /// Temperatura desde la que (hacia abajo) se considera "muy frío" y conviene
  /// pausar o reducir el riego.
  final double coldAlertC;

  /// Probabilidad de lluvia (%) desde la que se recomienda pausar el riego.
  final double rainPausePct;

  const IrrigationSettings({
    required this.minMoisture,
    required this.optimalMoisture,
    required this.maxMoisture,
    required this.hotAlertC,
    required this.coldAlertC,
    required this.rainPausePct,
  });

  static const initial = IrrigationSettings(
    minMoisture: 35,
    optimalMoisture: 58,
    maxMoisture: 70,
    hotAlertC: 28,
    coldAlertC: 10,
    rainPausePct: 50,
  );

  IrrigationSettings copyWith({
    double? minMoisture,
    double? optimalMoisture,
    double? maxMoisture,
    double? hotAlertC,
    double? coldAlertC,
    double? rainPausePct,
  }) {
    return IrrigationSettings(
      minMoisture: minMoisture ?? this.minMoisture,
      optimalMoisture: optimalMoisture ?? this.optimalMoisture,
      maxMoisture: maxMoisture ?? this.maxMoisture,
      hotAlertC: hotAlertC ?? this.hotAlertC,
      coldAlertC: coldAlertC ?? this.coldAlertC,
      rainPausePct: rainPausePct ?? this.rainPausePct,
    );
  }

  @override
  List<Object?> get props => [
    minMoisture,
    optimalMoisture,
    maxMoisture,
    hotAlertC,
    coldAlertC,
    rainPausePct,
  ];
}

class IrrigationSettingsCubit extends Cubit<IrrigationSettings> {
  IrrigationSettingsCubit() : super(IrrigationSettings.initial);

  void setMin(double value) => emit(state.copyWith(minMoisture: value));
  void setOptimal(double value) => emit(state.copyWith(optimalMoisture: value));
  void setMax(double value) => emit(state.copyWith(maxMoisture: value));
  void setHotAlert(double value) => emit(state.copyWith(hotAlertC: value));
  void setColdAlert(double value) => emit(state.copyWith(coldAlertC: value));
  void setRainPause(double value) => emit(state.copyWith(rainPausePct: value));

  void loadFromMap(Map<String, dynamic> map) {
    double? d(String key) => (map[key] as num?)?.toDouble();
    emit(state.copyWith(
      minMoisture: d('minMoisture'),
      optimalMoisture: d('optimalMoisture'),
      maxMoisture: d('maxMoisture'),
      hotAlertC: d('hotAlertC'),
      coldAlertC: d('coldAlertC'),
      rainPausePct: d('rainPausePct'),
    ));
  }
}

/// Tipo de aviso de riego que el motor de reglas devuelve a la UI.
enum IrrigationAdviceKind {
  rainPause,
  soilSoaked,
  heatBoost,
  coldHold,
  lowMoisture,
  ok,
  waiting,
}

class IrrigationAdvice {
  final IrrigationAdviceKind kind;
  final String key; // clave de l10n para el título
  final String? detailKey; // clave de l10n opcional para el detalle

  const IrrigationAdvice(this.kind, this.key, [this.detailKey]);
}

/// Aplica las reglas configuradas a la lectura actual y devuelve el consejo
/// que debe mostrar la card de clima.
IrrigationAdvice resolveIrrigationAdvice({
  required IrrigationSettings settings,
  required bool hasForecast,
  required double temperatureC,
  required int soilHumidityPct,
  required int? rainProbabilityPct,
}) {
  if (!hasForecast) {
    return const IrrigationAdvice(
      IrrigationAdviceKind.waiting,
      'waitingWeather',
    );
  }

  if (rainProbabilityPct != null &&
      rainProbabilityPct >= settings.rainPausePct) {
    return const IrrigationAdvice(
      IrrigationAdviceKind.rainPause,
      'adviceRainTitle',
      'adviceRainBody',
    );
  }

  if (soilHumidityPct >= settings.maxMoisture) {
    return const IrrigationAdvice(
      IrrigationAdviceKind.soilSoaked,
      'adviceSoakedTitle',
      'adviceSoakedBody',
    );
  }

  if (temperatureC <= settings.coldAlertC) {
    return const IrrigationAdvice(
      IrrigationAdviceKind.coldHold,
      'adviceColdTitle',
      'adviceColdBody',
    );
  }

  // Calor alto: dispara solo con la temperatura, sin depender de la humedad
  // (la regla de "tierra ya saturada" más arriba ya cubre el caso opuesto).
  if (temperatureC >= settings.hotAlertC) {
    return const IrrigationAdvice(
      IrrigationAdviceKind.heatBoost,
      'adviceHeatTitle',
      'adviceHeatBody',
    );
  }

  if (soilHumidityPct <= settings.minMoisture) {
    return const IrrigationAdvice(
      IrrigationAdviceKind.lowMoisture,
      'adviceLowMoistureTitle',
      'adviceLowMoistureBody',
    );
  }

  return const IrrigationAdvice(
    IrrigationAdviceKind.ok,
    'adviceOkTitle',
    'adviceOkBody',
  );
}
