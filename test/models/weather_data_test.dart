import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_data.dart';

void main() {
  group('WeatherData.fromJson', () {
    test('faz o parse correto da resposta da WeatherAPI', () {
      final json = {
        'current': {
          'temp_c': 18.5,
          'condition': {
            'text': 'Ensolarado',
            'icon': '//cdn.weatherapi.com/weather/64x64/day/113.png',
          },
          'humidity': 60,
          'wind_kph': 12.3,
        },
      };

      final weather = WeatherData.fromJson(json);

      expect(weather.temperatureC, 18.5);
      expect(weather.condition, 'Ensolarado');
      expect(
        weather.iconUrl,
        'https://cdn.weatherapi.com/weather/64x64/day/113.png',
      );
      expect(weather.humidity, 60);
      expect(weather.windKph, 12.3);
    });

    test('displayTemperature arredonda a temperatura', () {
      final json = {
        'current': {
          'temp_c': 18.6,
          'condition': {'text': 'Ensolarado', 'icon': '//x'},
          'humidity': 60,
          'wind_kph': 12.3,
        },
      };

      final weather = WeatherData.fromJson(json);

      expect(weather.displayTemperature, '19°C');
    });
  });
}
