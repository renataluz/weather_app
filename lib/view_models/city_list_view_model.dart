import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../repositories/weather_repository.dart';
import '../services/city_storage_service.dart';

enum AddCityResult { success, duplicate }

final cityStorageServiceProvider = Provider<CityStorageService>((ref) {
  return CityStorageService();
});

class CityListViewModel extends StateNotifier<List<City>> {
  CityListViewModel(this._storage, this._weatherRepository) : super([]) {
    _loadCities();
  }

  final CityStorageService _storage;
  final WeatherRepository _weatherRepository;

  Future<void> _loadCities() async {
    state = await _storage.loadCities();
  }

  Future<AddCityResult> addCityByName(String cityName) async {
    final city = await _weatherRepository.findCity(cityName);

    if (state.contains(city)) {
      return AddCityResult.duplicate;
    }

    state = [...state, city];
    await _storage.saveCities(state);
    return AddCityResult.success;
  }

  Future<void> removeCity(City city) async {
    state = state.where((c) => c != city).toList();
    await _storage.saveCities(state);
  }
}

final cityListProvider = StateNotifierProvider<CityListViewModel, List<City>>((
  ref,
) {
  return CityListViewModel(
    ref.watch(cityStorageServiceProvider),
    ref.watch(weatherRepositoryProvider),
  );
});
