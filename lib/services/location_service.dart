import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/app_strings.dart';
import '../models/coordinates.dart';

class LocationException implements Exception {
  final String message;

  LocationException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  Future<Coordinates> getCurrentCoordinates() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(AppStrings.locationServiceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(AppStrings.locationPermissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(AppStrings.locationPermissionDeniedForever);
    }

    final position = await Geolocator.getCurrentPosition();
    return Coordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

