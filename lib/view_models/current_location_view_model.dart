import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_strings.dart';
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

Future<void> openLocationSettings(WidgetRef ref) {
  return ref.read(locationServiceProvider).openLocationSettings();
}

Future<void> openAppSettings(WidgetRef ref) {
  return ref.read(locationServiceProvider).openAppSettings();
}

class LocationCardError {
  const LocationCardError({required this.message, this.onOpenSettings});

  final String message;
  final void Function(WidgetRef ref)? onOpenSettings;
}

LocationCardError describeLocationCardError(Object? error) {
  if (error is! LocationException) {
    return const LocationCardError(message: AppStrings.enableLocationPrompt);
  }

  switch (error.reason) {
    case LocationErrorReason.serviceDisabled:
      return LocationCardError(
        message: error.message,
        onOpenSettings: openLocationSettings,
      );
    case LocationErrorReason.permissionDenied:
    case LocationErrorReason.permissionDeniedForever:
      return LocationCardError(
        message: error.message,
        onOpenSettings: openAppSettings,
      );
    case LocationErrorReason.timeout:
      return LocationCardError(message: error.message);
  }
}
