import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../providers/weather_provider.dart';
import 'city_history_screen.dart';

class CityDetailScreen extends ConsumerWidget {
  const CityDetailScreen({super.key, required this.city});

  final City city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider(city.name));
    final forecastAsync = ref.watch(forecastProvider(city.name));

    return Scaffold(
      appBar: AppBar(
        title: Text(city.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CityHistoryScreen(city: city)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          weatherAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Erro: $error'),
            ),
            data: (weather) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Image.network(weather.iconUrl, width: 64, height: 64),
                  Text(
                    '${weather.temperatureC.round()}°C',
                    style: const TextStyle(fontSize: 40),
                  ),
                  Text(weather.condition),
                  Text(
                    'Umidade: ${weather.humidity}%  ·  Vento: ${weather.windKph} km/h',
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: forecastAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Erro: $error')),
              data: (days) => ListView.builder(
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  return ListTile(
                    leading: Image.network(day.iconUrl, width: 36, height: 36),
                    title: Text(_weekdayLabel(day.date)),
                    subtitle: Text(
                      '${day.condition} · chuva ${day.chanceOfRain}%',
                    ),
                    trailing: Text(
                      '${day.minTempC.round()}° / ${day.maxTempC.round()}°',
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(DateTime date) {
    const weekdays = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    return weekdays[date.weekday - 1];
  }
}
