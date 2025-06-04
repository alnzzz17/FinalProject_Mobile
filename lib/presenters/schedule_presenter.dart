import 'package:flutter/material.dart';
import 'package:tpm_fp/models/schedule_model.dart';
import 'package:tpm_fp/models/circuit_model.dart';
import 'package:tpm_fp/network/notification_service.dart';
import 'package:tpm_fp/network/schedule_service.dart';
import 'package:tpm_fp/models/data/circuit_data.dart';

class SchedulePresenter {
  final ScheduleService _service = ScheduleService();
  final NotificationService _notificationService = NotificationService();

  Future<void> init() async {
    await _service.init();
    await _notificationService.init();
  }

  Future<List<Schedule>> getSchedules() async {
    return await _service.getAllSchedules();
  }

  Future<void> saveSchedule({
    required String name,
    required String circuitId,
    required String type,
    required DateTime dateTime,
    bool notificationEnabled = true,
  }) async {
    final newSchedule = Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      circuitId: circuitId,
      type: type,
      dateTime: dateTime,
      notificationEnabled: notificationEnabled,
      createdAt: DateTime.now(),
    );

    await _service.saveSchedule(newSchedule);

    if (notificationEnabled) {
      await _notificationService.scheduleRaceNotifications(newSchedule);
    }
  }

  Future<void> updateSchedule({
    required String id,
    required String name,
    required String circuitId,
    required String type,
    required DateTime dateTime,
    bool notificationEnabled = true,
  }) async {
    final updatedSchedule = Schedule(
      id: id,
      name: name,
      circuitId: circuitId,
      type: type,
      dateTime: dateTime,
      notificationEnabled: notificationEnabled,
      createdAt: DateTime.now(),
    );

    await _notificationService.cancelNotifications(id.hashCode);
    await _service.saveSchedule(updatedSchedule);

    if (notificationEnabled) {
      await _notificationService.scheduleRaceNotifications(updatedSchedule);
    }
  }

  Future<void> deleteSchedule(String id) async {
    await _notificationService.cancelNotifications(id.hashCode);
    await _service.deleteSchedule(id);
  }

  List<Circuit> getCircuits() {
    return CircuitRepository.circuits;
  }

  List<String> getScheduleTypes() {
    return _service.getScheduleTypes();
  }

  Circuit? getCircuitById(String circuitId) {
    return CircuitRepository.getCircuitById(circuitId);
  }

  String formatDateTime(BuildContext context, DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}