import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_segment.dart';
import 'auth_bloc.dart';

/// Acceso al segmento del usuario autenticado desde cualquier widget.
///
/// La app adapta lo que muestra segun el segmento (informe 1.3 y User Task
/// Matrix 2.3.2): el principiante necesita que se le expliquen las lecturas,
/// el experto necesita los datos y los controles a la mano.
extension UserSegmentContext on BuildContext {
  /// Segmento actual. Por defecto principiante: ante la duda conviene
  /// explicar de mas y no esconder orientacion a quien la necesita.
  UserSegment get userSegment {
    final state = watch<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return UserSegment.fromApi(state.user.userType);
    }
    return UserSegment.beginner;
  }

  bool get isBeginnerUser => userSegment.isBeginner;
  bool get isExpertUser => userSegment.isExpert;
}
