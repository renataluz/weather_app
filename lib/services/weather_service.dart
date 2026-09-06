import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import '../models/city.dart';
import '../models/weather_data.dart';

class WeatherApiException implements Exception {
  final String message;
  WeatherApiException(this.message);

  @override
  String toString() => message;
}

class WeatherService {
  static const _baseUrl = 'https://api.weatherapi.com/v1';

  Future<WeatherData> getCurrentWeather(String cityName) async {
    final url = Uri.parse(
      '$_baseUrl/current.json?key=${Env.weatherApiKey}&q=$cityName&lang=pt',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherData.fromJson(json);
    }

    if (response.statusCode == 400) {
      throw WeatherApiException('Cidade não encontrada: $cityName');
    }

    throw WeatherApiException(
      'Erro ao buscar clima (status ${response.statusCode})',
    );
  }

  Future<City> findCity(String cityName) async {
    final url = Uri.parse(
      '$_baseUrl/search.json?key=${Env.weatherApiKey}&q=$cityName',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final results = jsonDecode(response.body) as List<dynamic>;

      if (results.isEmpty) {
        throw WeatherApiException('Cidade não encontrada: $cityName');
      }

      return City.fromJson(results.first as Map<String, dynamic>);
    }

    throw WeatherApiException(
      'Erro ao buscar cidade (status ${response.statusCode})',
    );
  }
}