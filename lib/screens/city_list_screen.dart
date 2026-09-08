import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/city_list_view_model.dart';
import '../view_models/current_location_view_model.dart';
import 'city_detail_screen.dart';
import '../view_models/weather_view_model.dart';
import '../constants/app_strings.dart';
import '../widgets/pulsing_placeholder.dart';

class CityListScreen extends ConsumerWidget {
  const CityListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(cityListProvider);
    final locationAsync = ref.watch(currentLocationWeatherProvider);

    final anyCityOffline = cities.any((city) {
      final cityWeatherAsync = ref.watch(weatherProvider(city.name));
      return cityWeatherAsync.hasError &&
          isNetworkError(cityWeatherAsync.error);
    });
    final isOffline =
        anyCityOffline ||
        (locationAsync.hasError && isNetworkError(locationAsync.error));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        title: const Text(AppStrings.appTitle),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(cityListProvider.notifier).refreshWeather(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (isOffline)
                Container(
                  width: double.infinity,
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 18,
                        color: Colors.orange.shade900,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.staleDataWarning,
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                        final messenger = ScaffoldMessenger.of(context);
                        ref.read(cityListProvider.notifier).removeCity(city);
                        messenger.clearSnackBars();
                        const undoSnackBarDuration = Duration(seconds: 4);
                        final controller = messenger.showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.cityRemoved(city.name)),
                            duration: undoSnackBarDuration,
                            action: SnackBarAction(
                              label: AppStrings.undo,
                              onPressed: () {
                                ref
                                    .read(cityListProvider.notifier)
                                    .restoreCity(city);
                              },
                            ),
                          ),
                        );
                        // O timer de auto-dismiss do próprio SnackBar não está
                        // disparando neste ambiente quando há um SnackBarAction
                        // (reproduzido até em um widget isolado, sem Riverpod).
                        // Como workaround, fechamos manualmente após a duração.
                        Timer(undoSnackBarDuration, controller.close);
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
                          onTap: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CityDetailScreen(city: city),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
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

    if (weatherAsync.hasValue) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (weatherAsync.hasError)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.wifi_off, size: 14, color: Colors.orange),
            ),
          Text(weatherAsync.value!.displayTemperature),
        ],
      );
    }

    if (weatherAsync.isLoading) {
      return const PulsingPlaceholder(width: 28, height: 14);
    }

    return const Icon(Icons.error_outline, size: 18);
  }
}

class _CityWeatherIcon extends ConsumerWidget {
  const _CityWeatherIcon({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider(cityName));

    if (weatherAsync.hasValue) {
      return Image.network(weatherAsync.value!.iconUrl, width: 32, height: 32);
    }

    if (weatherAsync.isLoading) {
      return const PulsingPlaceholder(
        width: 32,
        height: 32,
        shape: BoxShape.circle,
      );
    }

    return const Icon(Icons.cloud_off);
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

    if (weatherAsync.hasValue) {
      final location = weatherAsync.value!;
      final cardError = describeLocationCardError(weatherAsync.error);
      final onOpenSettings = cardError.onOpenSettings == null
          ? null
          : () => cardError.onOpenSettings!(ref);

      return Card(
        elevation: 3,
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CityDetailScreen(city: location.city),
              ),
            );
          },
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
              if (weatherAsync.hasError) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              weatherAsync.error.toString(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (onOpenSettings != null) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: onOpenSettings,
                            child: const Text(AppStrings.openSettings),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        ),
      );
    }

    if (weatherAsync.isLoading) {
      return _buildSkeleton(context);
    }

    if (isNetworkError(weatherAsync.error)) {
      return const SizedBox.shrink();
    }

    final cardError = describeLocationCardError(weatherAsync.error);
    final message = cardError.message;
    final onOpenSettings = cardError.onOpenSettings == null
        ? null
        : () => cardError.onOpenSettings!(ref);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ref.invalidate(currentLocationWeatherProvider),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onOpenSettings != null) ...[
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: onOpenSettings,
                  child: const Text(AppStrings.openSettings),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PulsingPlaceholder(width: 140, height: 12),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PulsingPlaceholder(
                  width: 56,
                  height: 56,
                  shape: BoxShape.circle,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PulsingPlaceholder(width: 100, height: 20),
                      const SizedBox(height: 8),
                      const PulsingPlaceholder(width: 70, height: 28),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
