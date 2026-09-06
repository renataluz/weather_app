class WeatherData {
  final double temperatureC;
  final String condition;
  final String iconUrl;
  final int humidity;
  final double windKph;

  const WeatherData({
    required this.temperatureC,
    required this.condition,
    required this.iconUrl,
    required this.humidity,
    required this.windKph,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final condition = current['condition'] as Map<String, dynamic>;

    return WeatherData(
      temperatureC: (current['temp_c'] as num).toDouble(),
      condition: condition['text'] as String,
      iconUrl: 'https:${condition['icon'] as String}',
      humidity: current['humidity'] as int,
      windKph: (current['wind_kph'] as num).toDouble(),
    );
  }
}