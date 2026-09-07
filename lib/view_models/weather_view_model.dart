import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_data.dart';
import '../repositories/weather_repository.dart';

final weatherProvider = FutureProvider.family<WeatherData, String>((ref, cityName) {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.getCurrentWeather(cityName);
});