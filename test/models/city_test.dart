import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/city.dart';

void main() {
  group('City', () {
    test('duas cidades com coordenadas iguais (arredondadas) são iguais', () {
      const cityA = City(
        name: 'São Paulo',
        country: 'Brazil',
        latitude: -23.5505,
        longitude: -46.6333,
      );
      const cityB = City(
        name: 'Sao Paulo',
        country: 'Brazil',
        latitude: -23.5504,
        longitude: -46.6333,
      );

      expect(cityA, equals(cityB));
      expect(cityA.hashCode, equals(cityB.hashCode));
    });

    test('cidades com coordenadas diferentes não são iguais', () {
      const cityA = City(
        name: 'São Paulo',
        country: 'Brazil',
        latitude: -23.5505,
        longitude: -46.6333,
      );
      const cityB = City(
        name: 'Rio de Janeiro',
        country: 'Brazil',
        latitude: -22.9068,
        longitude: -43.1729,
      );

      expect(cityA, isNot(equals(cityB)));
    });
  });
}
