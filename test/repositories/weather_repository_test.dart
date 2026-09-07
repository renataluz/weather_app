import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/city.dart';
import 'package:weather_app/models/forecast_day.dart';
import 'package:weather_app/models/history_day.dart';
import 'package:weather_app/models/weather_data.dart';
import 'package:weather_app/repositories/weather_repository.dart';
import 'package:weather_app/services/weather_service.dart';

class CountingWeatherService implements WeatherService {
  int getCurrentWeatherCallCount = 0;
  WeatherData? weatherToReturn;

  @override
  Future<WeatherData> getCurrentWeather(String cityName) async {
    getCurrentWeatherCallCount++;
    return weatherToReturn!;
  }

  @override
  Future<City> findCity(String cityName) => throw UnimplementedError();

  @override
  Future<List<ForecastDay>> getForecast(String cityName, {int days = 7}) =>
      throw UnimplementedError();

  @override
  Future<HistoryDay> getHistoryOneYearAgo(String cityName) =>
      throw UnimplementedError();
}

void main() {
  const sampleWeather = WeatherData(
    temperatureC: 20,
    condition: 'Ensolarado',
    iconUrl: 'https://x',
    humidity: 50,
    windKph: 10,
  );

  test('getCurrentWeather usa cache dentro da janela de tempo', () async {
    final service = CountingWeatherService()..weatherToReturn = sampleWeather;
    final repository = WeatherRepository(service);

    await repository.getCurrentWeather('Santos');
    await repository.getCurrentWeather('Santos');

    expect(service.getCurrentWeatherCallCount, 1);
  });

  test('invalidate força nova busca', () async {
    final service = CountingWeatherService()..weatherToReturn = sampleWeather;
    final repository = WeatherRepository(service);

    await repository.getCurrentWeather('Santos');
    repository.invalidate('Santos');
    await repository.getCurrentWeather('Santos');

    expect(service.getCurrentWeatherCallCount, 2);
  });

  test('cidades diferentes não compartilham cache', () async {
    final service = CountingWeatherService()..weatherToReturn = sampleWeather;
    final repository = WeatherRepository(service);

    await repository.getCurrentWeather('Santos');
    await repository.getCurrentWeather('São Paulo');

    expect(service.getCurrentWeatherCallCount, 2);
  });
}
