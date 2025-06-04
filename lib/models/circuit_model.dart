import 'package:hive/hive.dart';

part 'circuit_model.g.dart';

// Represents a MotoGP circuit with its location and timezone information.
@HiveType(typeId: 1)
class Circuit {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String location;
  
  @HiveField(3)
  final String timezone;
  
  @HiveField(4)
  final String flagEmoji;
  
  @HiveField(5)
  final double latitude;
  
  @HiveField(6)
  final double longitude;
  
  @HiveField(7)
  final String currency;

  Circuit({
    required this.id,
    required this.name,
    required this.location,
    required this.timezone,
    required this.flagEmoji,
    required this.latitude,
    required this.longitude,
    required this.currency,
  });

  @override
  String toString() => 'Circuit(id: $id, name: $name)';

  Circuit copyWith({
    String? id,
    String? name,
    String? location,
    String? timezone,
    String? flagEmoji,
    double? latitude,
    double? longitude,
    String? currency,
  }) {
    return Circuit(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      timezone: timezone ?? this.timezone,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      currency: currency ?? this.currency,
    );
  }
}