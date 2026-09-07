import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/view_models/weather_view_model.dart';
import '../models/city.dart';
import '../repositories/weather_repository.dart';
import '../services/city_storage_service.dart';
import 'city_detail_view_model.dart';

enum AddCityResult { success, duplicate }

final cityStorageServiceProvider = Provider<CityStorageService>((ref) {
  return CityStorageService();
});

class CityListViewModel extends StateNotifier<List<City>> {
  CityListViewModel(this._storage, this._weatherRepository, this._ref)
    : super([]) {
    _loadCities();
  }

  final CityStorageService _storage;
  final WeatherRepository _weatherRepository;
  final Ref _ref;

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

  Future<void> refreshWeather() async {
    final refreshes = state.map((city) {
      _weatherRepository.invalidate(city.name);
      _ref.invalidate(cityDetailProvider(city.name));
      return _ref.refresh(weatherProvider(city.name).future);
    });
    await Future.wait(refreshes);
  }
}

final cityListProvider = StateNotifierProvider<CityListViewModel, List<City>>((
  ref,
) {
  return CityListViewModel(
    ref.watch(cityStorageServiceProvider),
    ref.watch(weatherRepositoryProvider),
    ref,
  );
});
