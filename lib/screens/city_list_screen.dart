import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/city_list_provider.dart';
import '../providers/weather_provider.dart';

class CityListScreen extends ConsumerWidget {
  const CityListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(cityListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Climinha')),
      body: cities.isEmpty
          ? const Center(child: Text('Nenhuma cidade cadastrada ainda.'))
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
      data: (weather) => Text('${weather.temperatureC.round()}°C'),
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
      final city = await ref.read(weatherServiceProvider).findCity(cityName);
      final added = ref.read(cityListProvider.notifier).addCity(city);

      if (!mounted) return;

      if (added) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isLoading = false;
          _errorText = 'Essa cidade já está cadastrada.';
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
      title: const Text('Adicionar cidade'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Ex: São Paulo',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Adicionar'),
        ),
      ],
    );
  }
}