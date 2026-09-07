import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../providers/weather_provider.dart';

class CityHistoryScreen extends ConsumerWidget {
  const CityHistoryScreen({super.key, required this.city});

  final City city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider(city.name));

    return Scaffold(
      appBar: AppBar(title: Text('Histórico · ${city.name}')),
      body: Center(
        child: historyAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$error', textAlign: TextAlign.center),
          ),
          data: (history) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDisplayDate(history.date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Image.network(history.iconUrl, width: 64, height: 64),
              Text(
                '${history.avgTempC.round()}°C',
                style: const TextStyle(fontSize: 40),
              ),
              Text(history.condition),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDisplayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
