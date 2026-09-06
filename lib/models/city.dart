class City {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String,
      country: json['country'] as String,
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'lat': latitude,
      'lon': longitude,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is City && name == other.name && country == other.country;

  @override
  int get hashCode => Object.hash(name, country);
}