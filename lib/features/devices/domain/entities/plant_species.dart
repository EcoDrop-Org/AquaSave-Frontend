import 'package:equatable/equatable.dart';

/// Especie de planta que el usuario puede cuidar con AquaSave.
///
/// El catalogo vive en el front (y debe espejarse en el backend) a proposito:
/// los umbrales de humedad son el dato que decide si hay que regar, y ninguna
/// API publica los entrega de forma confiable. Al ser una lista estatica la
/// app funciona sin internet, sin cuota y sin posibilidad de caerse — algo
/// necesario para la demo (ver DOCS-BACKEND-PENDIENTE.md, seccion 3.5).
///
/// Las APIs externas (Perenual) quedan solo para la ficha informativa y la
/// foto, que son prescindibles.
class PlantSpecies extends Equatable {
  /// Identificador estable que viaja a la API. No traducir.
  final String id;

  /// Nombre que ve el usuario.
  final String commonName;

  /// Humedad de suelo minima: por debajo, la planta necesita agua.
  final int soilMinPct;

  /// Humedad de suelo maxima: por encima, hay riesgo de exceso de riego.
  final int soilMaxPct;

  /// Luz que necesita, en palabras del usuario.
  final String sunlight;

  /// Consejo breve propio de la especie (se muestra en la ficha).
  final String careTip;

  const PlantSpecies({
    required this.id,
    required this.commonName,
    required this.soilMinPct,
    required this.soilMaxPct,
    required this.sunlight,
    required this.careTip,
  });

  /// Humedad ideal, punto medio del rango.
  int get soilTargetPct => ((soilMinPct + soilMaxPct) / 2).round();

  /// true cuando la especie no esta en el catalogo ("Otra planta"): se usan
  /// umbrales genericos y no se muestran consejos de especie.
  bool get isGeneric => id == genericId;

  static const genericId = 'otra';

  @override
  List<Object?> get props => [id];
}

/// Catalogo de especies comunes en plantas domesticas de Lima.
///
/// Si se agregan especies, agregarlas tambien en el backend para que las
/// recomendaciones usen los mismos umbrales.
abstract final class PlantSpeciesCatalog {
  static const List<PlantSpecies> all = [
    PlantSpecies(
      id: 'albahaca',
      commonName: 'Albahaca',
      soilMinPct: 45,
      soilMaxPct: 70,
      sunlight: 'Sol directo 4-6 h',
      careTip:
          'Pellizca las flores en cuanto salgan: así la planta sigue dando '
          'hojas en lugar de semillas.',
    ),
    PlantSpecies(
      id: 'tomate',
      commonName: 'Tomate',
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Sol directo 6-8 h',
      careTip:
          'Riega la tierra, no las hojas. Mojar las hojas favorece los '
          'hongos.',
    ),
    PlantSpecies(
      id: 'lechuga',
      commonName: 'Lechuga',
      soilMinPct: 55,
      soilMaxPct: 80,
      sunlight: 'Sol parcial 3-5 h',
      careTip:
          'Necesita tierra fresca y húmeda. Si le falta agua las hojas '
          'amargan.',
    ),
    PlantSpecies(
      id: 'culantro',
      commonName: 'Culantro',
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Sol parcial 3-5 h',
      careTip:
          'Corta los tallos exteriores primero para que siga creciendo del '
          'centro.',
    ),
    PlantSpecies(
      id: 'menta',
      commonName: 'Menta',
      soilMinPct: 55,
      soilMaxPct: 80,
      sunlight: 'Sombra parcial',
      careTip:
          'Tenla en maceta propia: sus raíces invaden el espacio de las '
          'demás plantas.',
    ),
    PlantSpecies(
      id: 'perejil',
      commonName: 'Perejil',
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Sol parcial 3-5 h',
      careTip: 'Tarda en germinar; no te preocupes si demora semanas.',
    ),
    PlantSpecies(
      id: 'romero',
      commonName: 'Romero',
      soilMinPct: 25,
      soilMaxPct: 50,
      sunlight: 'Sol directo 6-8 h',
      careTip:
          'Prefiere quedarse seco. Es más fácil matarlo por exceso de riego '
          'que por falta.',
    ),
    PlantSpecies(
      id: 'oregano',
      commonName: 'Orégano',
      soilMinPct: 30,
      soilMaxPct: 55,
      sunlight: 'Sol directo 5-7 h',
      careTip: 'Deja secar la capa superior de tierra entre riegos.',
    ),
    PlantSpecies(
      id: 'aji',
      commonName: 'Ají',
      soilMinPct: 45,
      soilMaxPct: 70,
      sunlight: 'Sol directo 6-8 h',
      careTip: 'Con calor necesita más agua: revisa la humedad a diario.',
    ),
    PlantSpecies(
      id: 'fresa',
      commonName: 'Fresa',
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Sol directo 5-7 h',
      careTip:
          'Que los frutos no toquen la tierra húmeda para que no se pudran.',
    ),
    PlantSpecies(
      id: 'suculenta',
      commonName: 'Suculenta',
      soilMinPct: 10,
      soilMaxPct: 35,
      sunlight: 'Luz indirecta brillante',
      careTip:
          'Riega poco y espaciado. Guarda agua en sus hojas: el exceso la '
          'pudre.',
    ),
    PlantSpecies(
      id: 'aloe',
      commonName: 'Aloe vera',
      soilMinPct: 15,
      soilMaxPct: 40,
      sunlight: 'Luz indirecta brillante',
      careTip: 'Deja secar la tierra por completo antes del siguiente riego.',
    ),
    PlantSpecies(
      id: 'cactus',
      commonName: 'Cactus',
      soilMinPct: 5,
      soilMaxPct: 25,
      sunlight: 'Sol directo 6 h',
      careTip: 'En invierno casi no necesita agua.',
    ),
    PlantSpecies(
      id: 'potho',
      commonName: 'Potho',
      soilMinPct: 40,
      soilMaxPct: 65,
      sunlight: 'Luz indirecta',
      careTip:
          'Muy resistente: tolera que te olvides de regarla de vez en cuando.',
    ),
    PlantSpecies(
      id: 'sansevieria',
      commonName: 'Sansevieria',
      soilMinPct: 15,
      soilMaxPct: 40,
      sunlight: 'Luz indirecta, tolera sombra',
      careTip: 'Riega solo cuando la tierra esté seca varios centímetros.',
    ),
    // Fallback: umbrales genericos de planta de interior.
    PlantSpecies(
      id: PlantSpecies.genericId,
      commonName: 'Otra planta',
      soilMinPct: 40,
      soilMaxPct: 70,
      sunlight: 'Según la especie',
      careTip: '',
    ),
  ];

  /// Especies que se ofrecen para elegir (todas menos el fallback, que se
  /// muestra aparte al final de la lista).
  static List<PlantSpecies> get selectable =>
      all.where((s) => !s.isGeneric).toList();

  static PlantSpecies get generic =>
      all.firstWhere((s) => s.id == PlantSpecies.genericId);

  /// Resuelve una especie por su id. Devuelve la genérica si no se reconoce,
  /// para que la app nunca se quede sin umbrales con los que decidir.
  static PlantSpecies byId(String? id) {
    if (id == null || id.trim().isEmpty) return generic;
    final needle = id.trim().toLowerCase();
    return all.firstWhere(
      (s) => s.id == needle,
      orElse: () => generic,
    );
  }
}
