import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/city_list_view_model.dart';
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
      body: cities.isEmpty
          ? const Center(child: Text(AppStrings.emptyCityList))
          : ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                return Dismissible(
                  key: ValueKey('${city.name}-${city.country}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(cityListProvider.notifier).removeCity(city);
                  },
                  child: ListTile(
                    title: Text(city.name),
                    subtitle: Text(city.country),
                    trailing: _CityWeatherBadge(cityName: city.name),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CityDetailScreen(city: city),
                      ),
                    ),
                  ),
                );
              },
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
    if (cityName.isEmpty) return;

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
