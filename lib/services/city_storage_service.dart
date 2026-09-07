import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/city.dart';

class CityStorageService {
  static const _storageKey = 'saved_cities';

  Future<List<City>> loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];

    return jsonList
        .map((jsonStr) => City.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCities(List<City> cities) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = cities.map((city) => jsonEncode(city.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }
}