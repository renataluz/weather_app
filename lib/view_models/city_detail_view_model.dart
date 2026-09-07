import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/forecast_day.dart';
import '../models/weather_data.dart';
import '../repositories/weather_repository.dart';

class CityDetailData {
  final WeatherData weather;
  final List<ForecastDay> forecast;

  const CityDetailData({required this.weather, required this.forecast});
}

final cityDetailProvider = FutureProvider.family<CityDetailData, String>((
  ref,
  cityName,
) async {
  final repository = ref.watch(weatherRepositoryProvider);

  final weatherFuture = repository.getCurrentWeather(cityName);
  final forecastFuture = repository.getForecast(cityName);

  final weather = await weatherFuture;
  final forecast = await forecastFuture;

  return CityDetailData(weather: weather, forecast: forecast);
});
