class HistoryDay {
  final DateTime date;
  final double avgTempC;
  final String condition;
  final String iconUrl;

  const HistoryDay({
    required this.date,
    required this.avgTempC,
    required this.condition,
    required this.iconUrl,
  });

  factory HistoryDay.fromJson(Map<String, dynamic> json) {
    final day = json['day'] as Map<String, dynamic>;
    final condition = day['condition'] as Map<String, dynamic>;

    return HistoryDay(
      date: DateTime.parse(json['date'] as String),
      avgTempC: (day['avgtemp_c'] as num).toDouble(),
      condition: condition['text'] as String,
      iconUrl: 'https:${condition['icon'] as String}',
    );
  }
}
