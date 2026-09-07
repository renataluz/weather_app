import 'package:weather_app/models/city.dart';
import 'package:weather_app/models/forecast_day.dart';
import 'package:weather_app/models/history_day.dart';
import 'package:weather_app/models/weather_data.dart';
import 'package:weather_app/services/city_storage_service.dart';
import 'package:weather_app/services/weather_service.dart';

class FakeWeatherService implements WeatherService {
  City? cityToReturn;

  @override
  Future<City> findCity(String cityName) async {
    if (cityToReturn == null) {
      throw WeatherApiException('Cidade não encontrada: $cityName');
    }
    return cityToReturn!;
  }

  @override
  Future<WeatherData> getCurrentWeather(String cityName) =>
      throw UnimplementedError();

  @override
  Future<List<ForecastDay>> getForecast(String cityName, {int days = 7}) =>
      throw UnimplementedError();

  @override
  Future<HistoryDay> getHistoryOneYearAgo(String cityName) =>
      throw UnimplementedError();
}

class FakeCityStorageService implements CityStorageService {
  List<City> cities = [];

  @override
  Future<List<City>> loadCities() async => cities;

  @override
  Future<void> saveCities(List<City> newCities) async {
    cities = newCities;
  }
}
