class ForecastDay {
  final DateTime date;
  final double minTempC;
  final double maxTempC;
  final String condition;
  final String iconUrl;
  final int chanceOfRain;

  const ForecastDay({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.condition,
    required this.iconUrl,
    required this.chanceOfRain,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final day = json['day'] as Map<String, dynamic>;
    final condition = day['condition'] as Map<String, dynamic>;

    return ForecastDay(
      date: DateTime.parse(json['date'] as String),
      minTempC: (day['mintemp_c'] as num).toDouble(),
      maxTempC: (day['maxtemp_c'] as num).toDouble(),
      condition: condition['text'] as String,
      iconUrl: 'https:${condition['icon'] as String}',
      chanceOfRain: day['daily_chance_of_rain'] as int,
    );
  }
}
