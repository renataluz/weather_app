import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../services/city_storage_service.dart';

final cityStorageServiceProvider = Provider<CityStorageService>((ref) {
  return CityStorageService();
});

class CityListNotifier extends StateNotifier<List<City>> {
  CityListNotifier(this._storage) : super([]) {
    _loadCities();
  }

  final CityStorageService _storage;

  Future<void> _loadCities() async {
    state = await _storage.loadCities();
  }

  Future<bool> addCity(City city) async {
    if (state.contains(city)) {
      return false;
    }
    state = [...state, city];
    await _storage.saveCities(state);
    return true;
  }

  Future<void> removeCity(City city) async {
    state = state.where((c) => c != city).toList();
    await _storage.saveCities(state);
  }
}

final cityListProvider = StateNotifierProvider<CityListNotifier, List<City>>((
  ref,
) {
  return CityListNotifier(ref.watch(cityStorageServiceProvider));
});
