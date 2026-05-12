import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanCubit extends Cubit<String> {
  static const _storageKey = 'aquasave.plan';
  static const free = 'free';
  static const premium = 'premium';

  PlanCubit() : super(premium) {
    _load();
  }

  Future<void> setPlan(String plan) async {
    if (plan != free && plan != premium) return;
    emit(plan);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, plan);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == free || stored == premium) {
      emit(stored!);
    }
  }
}
