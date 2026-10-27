/// Segmentos objetivo del proyecto (ver informe, seccion 1.3).
///
/// AquaSave atiende dos segmentos definidos por el *nivel de experiencia* en
/// el cuidado de plantas, no por ubicacion:
///
/// - Principiante: se esta iniciando, necesita orientacion para interpretar
///   las lecturas y decidir cuando regar.
/// - Experto: tiene experiencia practica, busca historial, comparacion entre
///   periodos y control de la configuracion.
///
/// La UI se adapta a este valor: al principiante se le explican las lecturas
/// y se le dan acciones sugeridas; al experto se le exponen los datos crudos,
/// el historial y los parametros (ver User Task Matrix, seccion 2.3.2).
enum UserSegment {
  beginner('principiante'),
  expert('experto');

  const UserSegment(this.apiValue);

  /// Valor que viaja a la API en `profileType`.
  final String apiValue;

  /// Resuelve el segmento desde lo que devuelve la API.
  ///
  /// Los valores `horticultor-urbano` / `micro-agricultor-periurbano` son la
  /// segmentacion anterior (geografica) y siguen existiendo en las cuentas
  /// creadas antes de este cambio: se mapean a principiante para que esos
  /// usuarios no queden sin segmento. Ver `DOCS-BACKEND-PENDIENTE.md`.
  static UserSegment fromApi(String? raw) {
    return switch (raw) {
      'experto' => UserSegment.expert,
      'principiante' => UserSegment.beginner,
      // Cuentas antiguas (segmentacion geografica).
      'micro-agricultor-periurbano' => UserSegment.expert,
      'horticultor-urbano' => UserSegment.beginner,
      _ => UserSegment.beginner,
    };
  }

  /// true cuando el valor guardado todavia es de la segmentacion anterior y
  /// conviene pedirle al usuario que elija su nivel de experiencia.
  static bool isLegacy(String? raw) {
    return raw == 'horticultor-urbano' || raw == 'micro-agricultor-periurbano';
  }

  bool get isBeginner => this == UserSegment.beginner;
  bool get isExpert => this == UserSegment.expert;

  /// Clave de i18n para el nombre del segmento.
  String get labelKey =>
      isBeginner ? 'segmentBeginner' : 'segmentExpert';

  /// Clave de i18n para la descripcion corta que se muestra al elegirlo.
  String get descriptionKey =>
      isBeginner ? 'segmentBeginnerHint' : 'segmentExpertHint';
}
