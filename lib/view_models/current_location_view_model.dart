import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../models/weather_data.dart';
import '../repositories/weather_repository.dart';
import '../services/location_service.dart';

class CurrentLocationData {
  const CurrentLocationData({required this.city, required this.weather});

  final City city;
  final WeatherData weather;
}

final currentLocationWeatherProvider = FutureProvider<CurrentLocationData>((
  ref,
) async {
  final locationService = ref.watch(locationServiceProvider);
  final repository = ref.watch(weatherRepositoryProvider);

  final coordinates = await locationService.getCurrentCoordinates();
  final query = '${coordinates.latitude},${coordinates.longitude}';

  final cityFuture = repository.findCity(query);
  final weatherFuture = repository.getCurrentWeather(query);

  final city = await cityFuture;
  final weather = await weatherFuture;

  return CurrentLocationData(city: city, weather: weather);
});
