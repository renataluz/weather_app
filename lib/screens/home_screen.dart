import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider('London'));

    return Scaffold(
      appBar: AppBar(title: const Text('Climinha')),
      body: Center(
        child: weatherAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) => Text('Erro: $error'),
          data: (weather) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(weather.iconUrl),
              Text('${weather.temperatureC}°C', style: const TextStyle(fontSize: 32)),
              Text(weather.condition),
              Text('Umidade: ${weather.humidity}%'),
              Text('Vento: ${weather.windKph} km/h'),
            ],
          ),
        ),
      ),
    );
  }
}