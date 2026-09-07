import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/city_list_view_model.dart';
import '../view_models/current_location_view_model.dart';
import 'city_detail_screen.dart';
import '../view_models/weather_view_model.dart';
import '../constants/app_strings.dart';

class CityListScreen extends ConsumerWidget {
  const CityListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(cityListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(cityListProvider.notifier).refreshWeather(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const _CurrentLocationCard(),
            if (cities.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: Text(AppStrings.emptyCityList)),
              )
            else ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  AppStrings.listHint,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              ...cities.map(
                (city) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Dismissible(
                    key: ValueKey(city.uniqueKey),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      ref.read(cityListProvider.notifier).removeCity(city);
                    },
                    child: Card(
                      child: ListTile(
                        leading: _CityWeatherIcon(cityName: city.name),
                        title: Text(city.name),
                        subtitle: Text(city.country),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _CityWeatherBadge(cityName: city.name),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CityDetailScreen(city: city),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _AddCityDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CityWeatherBadge extends ConsumerWidget {
  const _CityWeatherBadge({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider(cityName));

    return weatherAsync.when(
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stackTrace) => const Icon(Icons.error_outline, size: 18),
      data: (weather) => Text(weather.displayTemperature),
    );
  }
}

class _CityWeatherIcon extends ConsumerWidget {
  const _CityWeatherIcon({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider(cityName));

    return weatherAsync.when(
      loading: () => const Icon(Icons.location_city),
      error: (error, stackTrace) => const Icon(Icons.location_city),
      data: (weather) =>
          Image.network(weather.iconUrl, width: 32, height: 32),
    );
  }
}

class _CurrentLocationCard extends ConsumerStatefulWidget {
  const _CurrentLocationCard();

  @override
  ConsumerState<_CurrentLocationCard> createState() =>
      _CurrentLocationCardState();
}

class _CurrentLocationCardState extends ConsumerState<_CurrentLocationCard> {
  bool _isAdding = false;

  Future<void> _addToList() async {
    setState(() => _isAdding = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await ref
          .read(cityListProvider.notifier)
          .addCurrentLocationCity();

      if (!mounted) return;

      if (result == AddCityResult.duplicate) {
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.cityAlreadyRegistered)),
        );
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(currentLocationWeatherProvider);
    final savedCities = ref.watch(cityListProvider);

    return weatherAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => ListTile(
        leading: const Icon(Icons.location_off),
        title: const Text(AppStrings.enableLocationPrompt),
        onTap: () => ref.invalidate(currentLocationWeatherProvider),
      ),
      data: (location) => Card(
        elevation: 3,
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.my_location,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.currentLocationLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    location.weather.iconUrl,
                    width: 56,
                    height: 56,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.city.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          location.weather.displayTemperature,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Text(location.weather.condition),
                        Text(
                          location.weather.displaySummary,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isAdding || !savedCities.contains(location.city)) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _isAdding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton.icon(
                          onPressed: _addToList,
                          icon: const Icon(Icons.add),
                          label: const Text(AppStrings.add),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCityDialog extends ConsumerStatefulWidget {
  const _AddCityDialog();

  @override
  ConsumerState<_AddCityDialog> createState() => _AddCityDialogState();
}

class _AddCityDialogState extends ConsumerState<_AddCityDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _submit() async {
    final cityName = _controller.text.trim();
    if (cityName.isEmpty) {
      setState(() {
        _errorText = AppStrings.emptyCityName;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final result = await ref
          .read(cityListProvider.notifier)
          .addCityByName(cityName);

      if (!mounted) return;

      if (result == AddCityResult.success) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isLoading = false;
          _errorText = AppStrings.cityAlreadyRegistered;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addCityDialogTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: AppStrings.addCityHint,
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(AppStrings.add),
        ),
      ],
    );
  }
}
