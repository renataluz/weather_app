import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/constants/app_strings.dart';
import '../models/city.dart';
import '../view_models/city_detail_view_model.dart';
import '../widgets/pulsing_placeholder.dart';
import 'city_history_screen.dart';

class CityDetailScreen extends ConsumerWidget {
  const CityDetailScreen({super.key, required this.city});

  final City city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(cityDetailProvider(city.name));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        title: Text(city.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: AppStrings.historyTooltip,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CityHistoryScreen(city: city)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: detailAsync.when(
          loading: () => _buildSkeleton(context),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('$error', textAlign: TextAlign.center),
            ),
          ),
          data: (detail) => Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Image.network(
                      detail.weather.iconUrl,
                      width: 64,
                      height: 64,
                    ),
                    Text(
                      detail.weather.displayTemperature,
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                    ),
                    Text(
                      detail.weather.condition,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      detail.weather.displaySummary,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  itemCount: detail.forecast.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final day = detail.forecast[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          day.iconUrl,
                          width: 36,
                          height: 36,
                        ),
                        title: Text(day.displayWeekday),
                        subtitle: Text(day.condition),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              day.displayRange,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  size: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${day.chanceOfRain}%',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            children: [
              PulsingPlaceholder(width: 64, height: 64, shape: BoxShape.circle),
              SizedBox(height: 12),
              PulsingPlaceholder(width: 100, height: 32),
              SizedBox(height: 8),
              PulsingPlaceholder(width: 140, height: 16),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const PulsingPlaceholder(
                    width: 36,
                    height: 36,
                    shape: BoxShape.circle,
                  ),
                  title: const PulsingPlaceholder(width: 80, height: 14),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: PulsingPlaceholder(width: 140, height: 12),
                  ),
                  trailing: const PulsingPlaceholder(width: 50, height: 14),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
