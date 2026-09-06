import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

final weatherProvider = FutureProvider.family<WeatherData, String>((ref, cityName) {
  final service = ref.watch(weatherServiceProvider);
  return service.getCurrentWeather(cityName);
});