import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/view_models/weather_view_model.dart';
import '../models/city.dart';
import '../repositories/weather_repository.dart';
import '../services/city_storage_service.dart';
import '../services/location_service.dart';
import 'city_detail_view_model.dart';
import 'current_location_view_model.dart';

enum AddCityResult { success, duplicate }

final cityStorageServiceProvider = Provider<CityStorageService>((ref) {
  return CityStorageService();
});

class CityListViewModel extends StateNotifier<List<City>> {
  CityListViewModel(
    this._storage,
    this._weatherRepository,
    this._ref,
    this._locationService,
  ) : super([]) {
    _loadCities();
  }

  final CityStorageService _storage;
  final WeatherRepository _weatherRepository;
  final Ref _ref;
  final LocationService _locationService;

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

  Future<void> restoreCity(City city) async {
    if (state.contains(city)) return;
    state = [...state, city];
    await _storage.saveCities(state);
  }

  Future<void> refreshWeather() async {
    _ref.invalidate(currentLocationWeatherProvider);

    final refreshes = state.map((city) async {
      _weatherRepository.invalidate(city.name);
      _ref.invalidate(cityDetailProvider(city.name));
      try {
        // ignore: unused_result
        await _ref.refresh(weatherProvider(city.name).future);
      } catch (_) {
        // Falha esperada (ex: sem internet) — o AsyncValue do provider já
        // guarda o erro sozinho; não deixamos isso derrubar o Future.wait
        // e travar o gesto de pull-to-refresh.
      }
    });
    await Future.wait(refreshes);
  }

  Future<AddCityResult> addCurrentLocationCity() async {
    final coordinates = await _locationService.getCurrentCoordinates();
    final query = '${coordinates.latitude},${coordinates.longitude}';
    return addCityByName(query);
  }
}

final cityListProvider = StateNotifierProvider<CityListViewModel, List<City>>((
  ref,
) {
  return CityListViewModel(
    ref.watch(cityStorageServiceProvider),
    ref.watch(weatherRepositoryProvider),
    ref,
    ref.watch(locationServiceProvider),
  );
});
