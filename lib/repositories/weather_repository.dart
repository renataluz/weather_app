import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../models/forecast_day.dart';
import '../models/history_day.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

class _CacheEntry<T> {
  _CacheEntry(this.value) : fetchedAt = DateTime.now();

  final T value;
  final DateTime fetchedAt;

  bool get isExpired =>
      DateTime.now().difference(fetchedAt) > WeatherRepository._cacheDuration;
}

class WeatherRepository {
  WeatherRepository(this._service);

  static const _cacheDuration = Duration(minutes: 5);

  final WeatherService _service;
  final Map<String, _CacheEntry<WeatherData>> _weatherCache = {};
  final Map<String, _CacheEntry<List<ForecastDay>>> _forecastCache = {};

  Future<WeatherData> getCurrentWeather(String cityName) async {
    final cached = _weatherCache[cityName];
    if (cached != null && !cached.isExpired) {
      return cached.value;
    }

    final weather = await _service.getCurrentWeather(cityName);
    _weatherCache[cityName] = _CacheEntry(weather);
    return weather;
  }

  Future<List<ForecastDay>> getForecast(String cityName) async {
    final cached = _forecastCache[cityName];
    if (cached != null && !cached.isExpired) {
      return cached.value;
    }

    final forecast = await _service.getForecast(cityName);
    _forecastCache[cityName] = _CacheEntry(forecast);
    return forecast;
  }

  Future<HistoryDay> getHistoryOneYearAgo(String cityName) {
    return _service.getHistoryOneYearAgo(cityName);
  }

  Future<City> findCity(String cityName) {
    return _service.findCity(cityName);
  }

  void invalidate(String cityName) {
    _weatherCache.remove(cityName);
    _forecastCache.remove(cityName);
  }
}

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(ref.watch(weatherServiceProvider));
});
