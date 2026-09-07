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

import '../fakes/weather_fakes.dart';

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