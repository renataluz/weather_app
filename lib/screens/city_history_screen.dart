import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/view_models/city_history_view_model.dart';
import '../constants/app_strings.dart';
import '../models/city.dart';
import '../widgets/pulsing_placeholder.dart';

class CityHistoryScreen extends ConsumerWidget {
  const CityHistoryScreen({super.key, required this.city});

  final City city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(cityHistoryProvider(city.name));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        title: Text(AppStrings.historyTitle(city.name)),
      ),
      body: SafeArea(
        child: Center(
          child: historyAsync.when(
            loading: () => Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PulsingPlaceholder(width: 100, height: 16),
                  SizedBox(height: 16),
                  PulsingPlaceholder(width: 64, height: 64, shape: BoxShape.circle),
                  SizedBox(height: 8),
                  PulsingPlaceholder(width: 90, height: 32),
                  SizedBox(height: 8),
                  PulsingPlaceholder(width: 130, height: 14),
                ],
              ),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('$error', textAlign: TextAlign.center),
            ),
            data: (history) => Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    history.displayDate,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.network(history.iconUrl, width: 64, height: 64),
                  Text(
                    history.displayTemperature,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    history.condition,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
