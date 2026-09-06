import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';

class CityListNotifier extends StateNotifier<List<City>> {
  CityListNotifier() : super([]);

  bool addCity(City city) {
    if (state.contains(city)) {
      return false;
    }
    state = [...state, city];
    return true;
  }

  void removeCity(City city) {
    state = state.where((c) => c != city).toList();
  }
}

final cityListProvider =
StateNotifierProvider<CityListNotifier, List<City>>((ref) {
  return CityListNotifier();
});