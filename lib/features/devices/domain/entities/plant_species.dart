import 'package:equatable/equatable.dart';

/// Categoria del catalogo, para agrupar el selector de especies.
enum PlantCategory {
  hierbas('hierbas', 'Hierbas aromáticas'),
  vegetales('vegetales', 'Vegetales'),
  frutas('frutas', 'Frutas'),
  suculentas('suculentas', 'Suculentas y cactus'),
  interior('interior', 'Plantas de interior'),
  flores('flores', 'Flores y orquídeas'),
  terraza('terraza', 'Plantas de terraza'),
  ;

  const PlantCategory(this.id, this.label);

  final String id;
  final String label;
}

/// Especie de planta que el usuario puede cuidar con AquaSave.
///
/// Debe mantenerse identico al catalogo del backend
/// (`device-management/domain/plant-species.ts`): si los umbrales
/// divergen, la app mostraria un rango distinto al que decide el riego.
///
/// Es estatico porque ninguna API publica da estos umbrales de forma
/// confiable. La foto y la descripcion si vienen del backend, que las
/// busca en Wikipedia por `scientificName`.
class PlantSpecies extends Equatable {
  /// Identificador estable que viaja a la API. No traducir.
  final String id;

  /// Nombre que ve el usuario.
  final String commonName;

  final PlantCategory category;

  /// Humedad de suelo minima: por debajo, la planta necesita agua.
  final int soilMinPct;

  /// Humedad de suelo maxima: por encima, hay exceso de riego.
  final int soilMaxPct;

  /// Luz que necesita, en palabras del usuario.
  final String sunlight;

  /// Consejo breve propio de la especie.
  final String careTip;

  /// Nombre cientifico, con el que el backend busca foto y ficha.
  final String scientificName;

  const PlantSpecies({
    required this.id,
    required this.commonName,
    required this.category,
    required this.soilMinPct,
    required this.soilMaxPct,
    required this.sunlight,
    required this.careTip,
    required this.scientificName,
  });

  /// Humedad ideal, punto medio del rango.
  int get soilTargetPct => ((soilMinPct + soilMaxPct) / 2).round();

  /// true cuando el usuario eligio "Otra planta" y escribio el nombre.
  bool get isGeneric => id == genericId;

  static const genericId = 'otra';

  @override
  List<Object?> get props => [id];
}

/// Catalogo de especies comunes en plantas domesticas de Lima.
abstract final class PlantSpeciesCatalog {
  static const List<PlantSpecies> all = [
    PlantSpecies(
      id: 'albahaca',
      commonName: 'Albahaca',
      category: PlantCategory.hierbas,
      soilMinPct: 45,
      soilMaxPct: 70,
      sunlight: 'Sol directo 4-6 h',
      careTip:
          'Pellizca las flores en cuanto salgan: asi la planta sigue '
          'dando hojas en lugar de semillas.',
      scientificName: 'Ocimum basilicum',
    ),
    PlantSpecies(
      id: 'menta',
      commonName: 'Menta',
      category: PlantCategory.hierbas,
      soilMinPct: 55,
      soilMaxPct: 80,
      sunlight: 'Sombra parcial',
      careTip:
          'Tenla en maceta propia: sus raices invaden el espacio de las '
          'demas plantas.',
      scientificName: 'Mentha',
    ),
    PlantSpecies(
      id: 'culantro',
      commonName: 'Culantro',
      category: PlantCategory.hierbas,
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Sol parcial 3-5 h',
      careTip:
          'Corta los tallos exteriores primero para que siga creciendo '
          'del centro.',
      scientificName: 'Coriandrum sativum',
    ),
    PlantSpecies(
      id: 'perejil',
      commonName: 'Perejil',
      category: PlantCategory.hierbas,
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Sol parcial 3-5 h',
      careTip: 'Tarda en germinar; no te preocupes si demora semanas.',
      scientificName: 'Petroselinum crispum',
    ),
    PlantSpecies(
      id: 'romero',
      commonName: 'Romero',
      category: PlantCategory.hierbas,
      soilMinPct: 25,
      soilMaxPct: 50,
      sunlight: 'Sol directo 6-8 h',
      careTip:
          'Prefiere quedarse seco. Es mas facil matarlo por exceso de '
          'riego que por falta.',
      scientificName: 'Salvia rosmarinus',
    ),
    PlantSpecies(
      id: 'oregano',
      commonName: 'Oregano',
      category: PlantCategory.hierbas,
      soilMinPct: 30,
      soilMaxPct: 55,
      sunlight: 'Sol directo 5-7 h',
      careTip: 'Deja secar la capa superior de tierra entre riegos.',
      scientificName: 'Origanum vulgare',
    ),
    PlantSpecies(
      id: 'tomillo',
      commonName: 'Tomillo',
      category: PlantCategory.hierbas,
      soilMinPct: 25,
      soilMaxPct: 50,
      sunlight: 'Sol directo 6-8 h',
      careTip:
          'Resiste la sequia: riega solo cuando la tierra este seca al '
          'tacto.',
      scientificName: 'Thymus vulgaris',
    ),
    PlantSpecies(
      id: 'hierbabuena',
      commonName: 'Hierbabuena',
      category: PlantCategory.hierbas,
      soilMinPct: 55,
      soilMaxPct: 80,
      sunlight: 'Sombra parcial',
      careTip: 'Pide tierra siempre humeda; no la dejes secar del todo.',
      scientificName: 'Mentha spicata',
    ),
    PlantSpecies(
      id: 'tomate',
      commonName: 'Tomate',
      category: PlantCategory.vegetales,
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Sol directo 6-8 h',
      careTip:
          'Riega la tierra, no las hojas. Mojar las hojas favorece los '
          'hongos.',
      scientificName: 'Solanum lycopersicum',
    ),
    PlantSpecies(
      id: 'lechuga',
      commonName: 'Lechuga',
      category: PlantCategory.vegetales,
      soilMinPct: 55,
      soilMaxPct: 80,
      sunlight: 'Sol parcial 3-5 h',
      careTip:
          'Necesita tierra fresca y humeda. Si le falta agua las hojas '
          'amargan.',
      scientificName: 'Lactuca sativa',
    ),
    PlantSpecies(
      id: 'aji',
      commonName: 'Aji',
      category: PlantCategory.vegetales,
      soilMinPct: 45,
      soilMaxPct: 70,
      sunlight: 'Sol directo 6-8 h',
      careTip: 'Con calor necesita mas agua: revisa la humedad a diario.',
      scientificName: 'Capsicum',
    ),
    PlantSpecies(
      id: 'espinaca',
      commonName: 'Espinaca',
      category: PlantCategory.vegetales,
      soilMinPct: 55,
      soilMaxPct: 80,
      sunlight: 'Sol parcial 3-5 h',
      careTip: 'Crece mejor en epoca fresca; con mucho calor se va a semilla.',
      scientificName: 'Spinacia oleracea',
    ),
    PlantSpecies(
      id: 'rabanito',
      commonName: 'Rabanito',
      category: PlantCategory.vegetales,
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Sol directo 4-6 h',
      careTip: 'Esta listo en un mes. Si le falta agua sale picante y fibroso.',
      scientificName: 'Raphanus sativus',
    ),
    PlantSpecies(
      id: 'zanahoria',
      commonName: 'Zanahoria',
      category: PlantCategory.vegetales,
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Sol directo 5-7 h',
      careTip:
          'Necesita tierra suelta y profunda para que la raiz crezca '
          'derecha.',
      scientificName: 'Daucus carota',
    ),
    PlantSpecies(
      id: 'cebolla-china',
      commonName: 'Cebolla china',
      category: PlantCategory.vegetales,
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Sol directo 5-7 h',
      careTip: 'Corta las hojas y vuelven a crecer varias veces.',
      scientificName: 'Allium fistulosum',
    ),
    PlantSpecies(
      id: 'fresa',
      commonName: 'Fresa',
      category: PlantCategory.frutas,
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Sol directo 5-7 h',
      careTip:
          'Que los frutos no toquen la tierra humeda para que no se '
          'pudran.',
      scientificName: 'Fragaria',
    ),
    PlantSpecies(
      id: 'limon',
      commonName: 'Limonero',
      category: PlantCategory.frutas,
      soilMinPct: 40,
      soilMaxPct: 65,
      sunlight: 'Sol directo 6-8 h',
      careTip:
          'En maceta necesita buen drenaje; el agua estancada pudre sus '
          'raices.',
      scientificName: 'Citrus limon',
    ),
    PlantSpecies(
      id: 'arandano',
      commonName: 'Arandano',
      category: PlantCategory.frutas,
      soilMinPct: 55,
      soilMaxPct: 80,
      sunlight: 'Sol directo 5-7 h',
      careTip: 'Pide tierra acida y humeda constante.',
      scientificName: 'Vaccinium',
    ),
    PlantSpecies(
      id: 'suculenta',
      commonName: 'Suculenta',
      category: PlantCategory.suculentas,
      soilMinPct: 10,
      soilMaxPct: 35,
      sunlight: 'Luz indirecta brillante',
      careTip:
          'Riega poco y espaciado. Guarda agua en sus hojas: el exceso la '
          'pudre.',
      scientificName: 'Planta suculenta',
    ),
    PlantSpecies(
      id: 'cactus',
      commonName: 'Cactus',
      category: PlantCategory.suculentas,
      soilMinPct: 5,
      soilMaxPct: 25,
      sunlight: 'Sol directo 6 h',
      careTip: 'En invierno casi no necesita agua.',
      scientificName: 'Cactaceae',
    ),
    PlantSpecies(
      id: 'aloe',
      commonName: 'Aloe vera',
      category: PlantCategory.suculentas,
      soilMinPct: 15,
      soilMaxPct: 40,
      sunlight: 'Luz indirecta brillante',
      careTip: 'Deja secar la tierra por completo antes del siguiente riego.',
      scientificName: 'Aloe vera',
    ),
    PlantSpecies(
      id: 'echeveria',
      commonName: 'Echeveria',
      category: PlantCategory.suculentas,
      soilMinPct: 10,
      soilMaxPct: 30,
      sunlight: 'Luz indirecta brillante',
      careTip:
          'Riega en la tierra, nunca sobre la roseta: el agua al centro '
          'la pudre.',
      scientificName: 'Echeveria',
    ),
    PlantSpecies(
      id: 'potho',
      commonName: 'Potho',
      category: PlantCategory.interior,
      soilMinPct: 40,
      soilMaxPct: 65,
      sunlight: 'Luz indirecta',
      careTip:
          'Muy resistente: tolera que te olvides de regarla de vez en '
          'cuando.',
      scientificName: 'Epipremnum aureum',
    ),
    PlantSpecies(
      id: 'sansevieria',
      commonName: 'Sansevieria',
      category: PlantCategory.interior,
      soilMinPct: 15,
      soilMaxPct: 40,
      sunlight: 'Luz indirecta, tolera sombra',
      careTip: 'Riega solo cuando la tierra este seca varios centimetros.',
      scientificName: 'Dracaena trifasciata',
    ),
    PlantSpecies(
      id: 'helecho',
      commonName: 'Helecho',
      category: PlantCategory.interior,
      soilMinPct: 60,
      soilMaxPct: 85,
      sunlight: 'Sombra o luz filtrada',
      careTip: 'Necesita humedad alta: rociar las hojas le hace bien.',
      scientificName: 'Nephrolepis exaltata',
    ),
    PlantSpecies(
      id: 'ficus',
      commonName: 'Ficus',
      category: PlantCategory.interior,
      soilMinPct: 40,
      soilMaxPct: 65,
      sunlight: 'Luz indirecta brillante',
      careTip: 'No le gusta que la muevan de sitio; pierde hojas al cambiarla.',
      scientificName: 'Ficus benjamina',
    ),
    PlantSpecies(
      id: 'bambu',
      commonName: 'Bambu de la suerte',
      category: PlantCategory.interior,
      soilMinPct: 55,
      soilMaxPct: 80,
      sunlight: 'Luz indirecta',
      careTip: 'Crece en agua o en tierra siempre humeda.',
      scientificName: 'Dracaena sanderiana',
    ),
    PlantSpecies(
      id: 'lirio-paz',
      commonName: 'Lirio de la paz',
      category: PlantCategory.interior,
      soilMinPct: 50,
      soilMaxPct: 75,
      sunlight: 'Luz indirecta, tolera sombra',
      careTip: 'Cuando le falta agua baja las hojas: es su forma de avisarte.',
      scientificName: 'Spathiphyllum',
    ),
    PlantSpecies(
      id: 'orquidea',
      commonName: 'Orquidea',
      category: PlantCategory.flores,
      soilMinPct: 35,
      soilMaxPct: 60,
      sunlight: 'Luz indirecta brillante',
      careTip:
          'No riegues la tierra: moja las raices y deja escurrir. El agua '
          'estancada las pudre.',
      scientificName: 'Orchidaceae',
    ),
    PlantSpecies(
      id: 'rosa',
      commonName: 'Rosa',
      category: PlantCategory.flores,
      soilMinPct: 45,
      soilMaxPct: 70,
      sunlight: 'Sol directo 6 h',
      careTip: 'Riega en la base por la manana; mojar las hojas trae hongos.',
      scientificName: 'Rosa',
    ),
    PlantSpecies(
      id: 'violeta',
      commonName: 'Violeta africana',
      category: PlantCategory.flores,
      soilMinPct: 45,
      soilMaxPct: 70,
      sunlight: 'Luz indirecta',
      careTip:
          'Riega por abajo, en el platito: sus hojas se manchan si se '
          'mojan.',
      scientificName: 'Saintpaulia',
    ),
    PlantSpecies(
      id: 'girasol',
      commonName: 'Girasol',
      category: PlantCategory.flores,
      soilMinPct: 45,
      soilMaxPct: 70,
      sunlight: 'Sol directo 6-8 h',
      careTip: 'Bebe mucha agua mientras crece; en maceta revisala a diario.',
      scientificName: 'Helianthus annuus',
    ),
    PlantSpecies(
      id: 'hortensia',
      commonName: 'Hortensia',
      category: PlantCategory.flores,
      soilMinPct: 55,
      soilMaxPct: 80,
      sunlight: 'Sombra parcial',
      careTip: 'El color de sus flores cambia con la acidez de la tierra.',
      scientificName: 'Hydrangea',
    ),
    PlantSpecies(
      id: 'geranio',
      commonName: 'Geranio',
      category: PlantCategory.terraza,
      soilMinPct: 35,
      soilMaxPct: 60,
      sunlight: 'Sol directo 5-7 h',
      careTip:
          'Quita las flores secas y seguira floreciendo toda la '
          'temporada.',
      scientificName: 'Pelargonium',
    ),
    PlantSpecies(
      id: 'petunia',
      commonName: 'Petunia',
      category: PlantCategory.terraza,
      soilMinPct: 40,
      soilMaxPct: 65,
      sunlight: 'Sol directo 5-6 h',
      careTip:
          'En maceta colgante se seca rapido: revisala a diario en '
          'verano.',
      scientificName: 'Petunia',
    ),
    PlantSpecies(
      id: 'lavanda',
      commonName: 'Lavanda',
      category: PlantCategory.terraza,
      soilMinPct: 20,
      soilMaxPct: 45,
      sunlight: 'Sol directo 6-8 h',
      careTip: 'Odia el exceso de agua. Necesita drenaje muy suelto.',
      scientificName: 'Lavandula',
    ),
    PlantSpecies(
      id: 'bugambilia',
      commonName: 'Bugambilia',
      category: PlantCategory.terraza,
      soilMinPct: 25,
      soilMaxPct: 50,
      sunlight: 'Sol directo 6-8 h',
      careTip:
          'Florece mas cuando se le riega poco; el exceso le da solo '
          'hojas.',
      scientificName: 'Bougainvillea',
    ),
    PlantSpecies(
      id: 'jazmin',
      commonName: 'Jazmin',
      category: PlantCategory.terraza,
      soilMinPct: 45,
      soilMaxPct: 70,
      sunlight: 'Sol parcial 4-6 h',
      careTip: 'Necesita algo donde trepar para crecer bien.',
      scientificName: 'Jasminum',
    ),
    PlantSpecies(
      id: 'clavel',
      commonName: 'Clavel',
      category: PlantCategory.terraza,
      soilMinPct: 40,
      soilMaxPct: 65,
      sunlight: 'Sol directo 5-7 h',
      careTip: 'Pide buen drenaje; no dejes agua en el platito.',
      scientificName: 'Dianthus caryophyllus',
    ),
    PlantSpecies(
      id: 'otra',
      commonName: 'Otra planta',
      category: PlantCategory.interior,
      soilMinPct: 40,
      soilMaxPct: 70,
      sunlight: 'Segun la especie',
      careTip: '',
      scientificName: '',
    ),
  ];

  /// Especies seleccionables (sin el fallback "Otra planta").
  static List<PlantSpecies> get selectable =>
      all.where((s) => !s.isGeneric).toList();

  static PlantSpecies get generic =>
      all.firstWhere((s) => s.id == PlantSpecies.genericId);

  /// Especies de una categoria, en el orden del catalogo.
  static List<PlantSpecies> byCategory(PlantCategory category) =>
      selectable.where((s) => s.category == category).toList();

  /// Busca por nombre; vacio devuelve todas.
  static List<PlantSpecies> search(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return selectable;
    return selectable
        .where(
          (s) =>
              s.commonName.toLowerCase().contains(needle) ||
              s.scientificName.toLowerCase().contains(needle) ||
              s.category.label.toLowerCase().contains(needle),
        )
        .toList();
  }

  /// Resuelve por id. Devuelve la generica si no se reconoce, para
  /// que la app nunca se quede sin umbrales.
  static PlantSpecies byId(String? id) {
    if (id == null || id.trim().isEmpty) return generic;
    final needle = id.trim().toLowerCase();
    return all.firstWhere((s) => s.id == needle, orElse: () => generic);
  }
}
