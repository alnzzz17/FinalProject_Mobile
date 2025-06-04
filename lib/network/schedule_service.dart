import 'package:hive/hive.dart';
import 'package:tpm_fp/models/schedule_model.dart';
import 'package:tpm_fp/models/circuit_model.dart';
import 'package:tpm_fp/models/data/circuit_data.dart';

class ScheduleService {
  static const String _scheduleBoxName = 'schedules';

  Future<void> init() async {
    await Hive.openBox<Schedule>(_scheduleBoxName);
  }

  Future<List<Schedule>> getAllSchedules() async {
    final box = Hive.box<Schedule>(_scheduleBoxName);
    return box.values.toList();
  }

  Future<void> saveSchedule(Schedule schedule) async {
    final box = Hive.box<Schedule>(_scheduleBoxName);
    await box.put(schedule.id, schedule);
  }

  Future<void> deleteSchedule(String id) async {
    final box = Hive.box<Schedule>(_scheduleBoxName);
    await box.delete(id);
  }

  List<Circuit> getCircuits() {
    return CircuitRepository.circuits;
  }

  List<String> getScheduleTypes() {
    return [
      'Practice 1 (FP1)',
      'Practice 2 (P2)',
      'Free Practice 3 (FP3)',
      'Qualifying 1 (Q1)',
      'Qualifying 2 (Q2)',
      'Sprint Race',
      'Main Race',
    ];
  }
}
