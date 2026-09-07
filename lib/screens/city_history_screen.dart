import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/view_models/city_history_view_model.dart';
import '../constants/app_strings.dart';
import '../models/city.dart';

class CityHistoryScreen extends ConsumerWidget {
  const CityHistoryScreen({super.key, required this.city});

  final City city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(cityHistoryProvider(city.name));

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.historyTitle(city.name))),
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
                history.displayDate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Image.network(history.iconUrl, width: 64, height: 64),
              Text(
                history.displayTemperature,
                style: const TextStyle(fontSize: 40),
              ),
              Text(history.condition),
            ],
          ),
        ),
      ),
    );
  }
}
