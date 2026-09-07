import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/city.dart';
import 'package:weather_app/models/forecast_day.dart';
import 'package:weather_app/models/history_day.dart';
import 'package:weather_app/models/weather_data.dart';
import 'package:weather_app/repositories/weather_repository.dart';
import 'package:weather_app/services/city_storage_service.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/view_models/city_list_view_model.dart';

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

void main() {
  const santos = City(
    name: 'Santos',
    country: 'Brazil',
    latitude: -23.9608,
    longitude: -46.3339,
  );

  late ProviderContainer container;

  setUp(() {
    final fakeService = FakeWeatherService()..cityToReturn = santos;

    container = ProviderContainer(
      overrides: [
        cityStorageServiceProvider.overrideWithValue(FakeCityStorageService()),
        weatherRepositoryProvider.overrideWithValue(
          WeatherRepository(fakeService),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  test('addCityByName adiciona uma cidade nova com sucesso', () async {
    final viewModel = container.read(cityListProvider.notifier);

    await Future<void>.delayed(Duration.zero);

    final result = await viewModel.addCityByName('Santos');

    expect(result, AddCityResult.success);
    expect(viewModel.state, contains(santos));
  });

  test('addCityByName recusa cidade duplicada', () async {
    final viewModel = container.read(cityListProvider.notifier);

    await Future<void>.delayed(Duration.zero);

    await viewModel.addCityByName('Santos');
    final secondResult = await viewModel.addCityByName('Santos');

    expect(secondResult, AddCityResult.duplicate);
    expect(viewModel.state.length, 1);
  });
}