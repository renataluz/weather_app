import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_day.dart';
import '../repositories/weather_repository.dart';

final cityHistoryProvider = FutureProvider.family<HistoryDay, String>((
  ref,
  cityName,
) {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.getHistoryOneYearAgo(cityName);
});
