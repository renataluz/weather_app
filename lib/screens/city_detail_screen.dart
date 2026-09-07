import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/constants/app_strings.dart';
import '../models/city.dart';
import '../view_models/city_detail_view_model.dart';
import 'city_history_screen.dart';

class CityDetailScreen extends ConsumerWidget {
  const CityDetailScreen({super.key, required this.city});

  final City city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(cityDetailProvider(city.name));

    return Scaffold(
      appBar: AppBar(
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
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$error', textAlign: TextAlign.center),
          ),
        ),
        data: (detail) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Image.network(detail.weather.iconUrl, width: 64, height: 64),
                  Text(
                    detail.weather.displayTemperature,
                    style: const TextStyle(fontSize: 40),
                  ),
                  Text(detail.weather.condition),
                  Text(detail.weather.displaySummary),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: detail.forecast.length,
                itemBuilder: (context, index) {
                  final day = detail.forecast[index];
                  return ListTile(
                    leading: Image.network(day.iconUrl, width: 36, height: 36),
                    title: Text(day.displayWeekday),
                    subtitle: Text(day.displaySubtitle),
                    trailing: Text(day.displayRange),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
