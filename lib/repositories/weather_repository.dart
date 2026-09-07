import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../models/forecast_day.dart';
import '../models/history_day.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

class WeatherRepository {
  WeatherRepository(this._service);

  final WeatherService _service;

  Future<WeatherData> getCurrentWeather(String cityName) {
    return _service.getCurrentWeather(cityName);
  }

  Future<List<ForecastDay>> getForecast(String cityName) {
    return _service.getForecast(cityName);
  }

  Future<HistoryDay> getHistoryOneYearAgo(String cityName) {
    return _service.getHistoryOneYearAgo(cityName);
  }

  Future<City> findCity(String cityName) {
    return _service.findCity(cityName);
  }
}

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(ref.watch(weatherServiceProvider));
});
