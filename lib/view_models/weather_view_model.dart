import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_strings.dart';
import '../models/weather_data.dart';
import '../repositories/weather_repository.dart';
import '../services/weather_service.dart';

final weatherProvider = FutureProvider.family<WeatherData, String>((ref, cityName) {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.getCurrentWeather(cityName);
});

bool isNetworkError(Object? error) {
  return error is WeatherApiException && error.message == AppStrings.networkError;
}