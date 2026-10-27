import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/remote/species_info_datasource.dart';

/// Fichas de especies ya cargadas, por id de especie.
///
/// Se mantiene en un cubit porque varias pantallas muestran la misma foto
/// (lista de plantas, detalle, wizard) y no tiene sentido pedirla de nuevo:
/// el backend ya la cachea, pero esto evita incluso la ida y vuelta.
class SpeciesInfoCubit extends Cubit<Map<String, SpeciesInfo>> {
  final SpeciesInfoDataSource remote;

  /// Ids que ya se pidieron, para no repetir peticiones fallidas en bucle.
  final Set<String> _requested = {};

  SpeciesInfoCubit({required this.remote}) : super(const {});

  SpeciesInfo? infoFor(String? speciesId) =>
      speciesId == null ? null : state[speciesId];

  /// Carga las fichas que falten. Es seguro llamarla en cada build.
  Future<void> ensureLoaded(Iterable<String> speciesIds) async {
    final missing = speciesIds
        .where((id) => id.trim().isNotEmpty && !_requested.contains(id))
        .toSet();
    if (missing.isEmpty) return;

    _requested.addAll(missing);

    try {
      final fetched = await remote.fetch(missing.toList());
      if (isClosed || fetched.isEmpty) return;
      emit({...state, ...fetched});
    } catch (_) {
      // Sin ficha las tarjetas muestran su icono: no es un error que deba
      // interrumpir la pantalla.
    }
  }
}
