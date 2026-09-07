import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/constants/app_strings.dart';
import 'package:weather_app/models/city.dart';
import 'package:weather_app/repositories/weather_repository.dart';
import 'package:weather_app/screens/city_list_screen.dart';
import 'package:weather_app/view_models/city_list_view_model.dart';

import '../fakes/weather_fakes.dart';

void main() {
  const santos = City(
    name: 'Santos',
    country: 'Brazil',
    latitude: -23.9608,
    longitude: -46.3339,
  );

  Widget buildTestApp({
    required FakeWeatherService fakeService,
    required FakeCityStorageService fakeStorage,
  }) {
    return ProviderScope(
      overrides: [
        cityStorageServiceProvider.overrideWithValue(fakeStorage),
        weatherRepositoryProvider.overrideWithValue(
          WeatherRepository(fakeService),
        ),
      ],
      child: const MaterialApp(home: CityListScreen()),
    );
  }

  testWidgets('mostra mensagem quando não há cidades cadastradas', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        fakeService: FakeWeatherService(),
        fakeStorage: FakeCityStorageService(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.emptyCityList), findsOneWidget);
  });

  testWidgets('adiciona uma cidade nova através do diálogo', (tester) async {
    final fakeService = FakeWeatherService()..cityToReturn = santos;

    await tester.pumpWidget(
      buildTestApp(
        fakeService: fakeService,
        fakeStorage: FakeCityStorageService(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Santos');
    await tester.tap(find.text(AppStrings.add));
    await tester.pumpAndSettle();

    expect(find.text('Santos'), findsOneWidget);
  });

  testWidgets('recusa cidade duplicada mostrando mensagem de erro', (
    tester,
  ) async {
    final fakeService = FakeWeatherService()..cityToReturn = santos;
    final fakeStorage = FakeCityStorageService()..cities = [santos];

    await tester.pumpWidget(
      buildTestApp(fakeService: fakeService, fakeStorage: fakeStorage),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Santos');
    await tester.tap(find.text(AppStrings.add));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.cityAlreadyRegistered), findsOneWidget);
  });
}
