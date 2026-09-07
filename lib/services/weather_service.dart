import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import '../models/city.dart';
import '../models/forecast_day.dart';
import '../models/history_day.dart';
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

  Future<List<ForecastDay>> getForecast(String cityName, {int days = 7}) async {
    final url = Uri.parse(
      '$_baseUrl/forecast.json?key=${Env.weatherApiKey}&q=$cityName&days=$days&lang=pt',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final forecast = json['forecast'] as Map<String, dynamic>;
      final forecastDays = forecast['forecastday'] as List<dynamic>;

      return forecastDays
          .map((day) => ForecastDay.fromJson(day as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 400) {
      throw WeatherApiException('Cidade não encontrada: $cityName');
    }

    throw WeatherApiException(
      'Erro ao buscar previsão (status ${response.statusCode})',
    );
  }

  Future<HistoryDay> getHistoryOneYearAgo(String cityName) async {
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
    final dateParam = _formatDate(oneYearAgo);

    final url = Uri.parse(
      '$_baseUrl/history.json?key=${Env.weatherApiKey}&q=$cityName&dt=$dateParam&lang=pt',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final forecast = json['forecast'] as Map<String, dynamic>;
      final forecastDays = forecast['forecastday'] as List<dynamic>;
      return HistoryDay.fromJson(forecastDays.first as Map<String, dynamic>);
    }

    if (response.statusCode == 400) {
      throw WeatherApiException('Cidade não encontrada: $cityName');
    }

    if (response.statusCode == 403) {
      throw WeatherApiException(
        'Histórico indisponível: esse recurso pode exigir um plano pago da WeatherAPI.',
      );
    }

    throw WeatherApiException(
      'Erro ao buscar histórico (status ${response.statusCode})',
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
