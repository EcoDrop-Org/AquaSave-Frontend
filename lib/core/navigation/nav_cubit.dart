import 'package:flutter_bloc/flutter_bloc.dart';

/// Tabs disponibles en el shell principal de la app.
enum AppTab { home, devices, analysis, history, profile, settings }

/// Cubit ligero para pedir un cambio de tab desde cualquier parte de la app
/// (por ejemplo, un enlace dentro de un diálogo que debe llevar al historial).
class NavCubit extends Cubit<AppTab> {
  NavCubit() : super(AppTab.home);

  void goTo(AppTab tab) => emit(tab);
}
