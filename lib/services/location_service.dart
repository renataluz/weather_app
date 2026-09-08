import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/app_strings.dart';
import '../models/coordinates.dart';

enum LocationErrorReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
}

class LocationException implements Exception {
  final String message;
  final LocationErrorReason reason;

  LocationException(this.message, this.reason);

  @override
  String toString() => message;
}

class LocationService {
  Future<Coordinates> getCurrentCoordinates() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        AppStrings.locationServiceDisabled,
        LocationErrorReason.serviceDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      try {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 15),
        );
      } on TimeoutException {
        throw LocationException(
          AppStrings.locationTimeout,
          LocationErrorReason.timeout,
        );
      }
      if (permission == LocationPermission.denied) {
        throw LocationException(
          AppStrings.locationPermissionDenied,
          LocationErrorReason.permissionDenied,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        AppStrings.locationPermissionDeniedForever,
        LocationErrorReason.permissionDeniedForever,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 10),
        ),
      );
      return Coordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on TimeoutException {
      throw LocationException(
        AppStrings.locationTimeout,
        LocationErrorReason.timeout,
      );
    }
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

