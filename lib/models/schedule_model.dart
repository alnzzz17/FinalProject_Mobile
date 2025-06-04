import 'package:hive/hive.dart';

part 'schedule_model.g.dart';

@HiveType(typeId: 2)
class Schedule {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String circuitId;
  
  @HiveField(3)
  final String type;
  
  @HiveField(4)
  final DateTime dateTime;
  
  @HiveField(5)
  final bool notificationEnabled;
  
  @HiveField(6)
  final DateTime createdAt;

  Schedule({
    required this.id,
    required this.name,
    required this.circuitId,
    required this.type,
    required this.dateTime,
    this.notificationEnabled = true,
    required this.createdAt,
  });

  Schedule copyWith({
    String? id,
    String? name,
    String? circuitId,
    String? type,
    DateTime? dateTime,
    bool? notificationEnabled,
    DateTime? createdAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      circuitId: circuitId ?? this.circuitId,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}