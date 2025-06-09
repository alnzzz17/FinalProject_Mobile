import 'package:flutter/material.dart';
import 'package:tpm_fp/models/schedule_model.dart';
import 'package:tpm_fp/models/circuit_model.dart';
import 'package:tpm_fp/network/notification_service.dart';
import 'package:tpm_fp/network/schedule_service.dart';
import 'package:tpm_fp/models/data/circuit_data.dart';

class SchedulePresenter {
  ScheduleService service = ScheduleService();
  NotificationService notificationService = NotificationService();

  Future<void> init() async {
    await service.init();
    await notificationService.init();
  }

  Future<List<Schedule>> getSchedules() async {
    return await service.getAllSchedules();
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

    await service.saveSchedule(newSchedule);

    if (notificationEnabled) {
      await notificationService.scheduleRaceNotifications(newSchedule);
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

    await notificationService.cancelNotifications(id.hashCode);
    await service.saveSchedule(updatedSchedule);

    if (notificationEnabled) {
      await notificationService.scheduleRaceNotifications(updatedSchedule);
    }
  }

  Future<void> deleteSchedule(String id) async {
    await notificationService.cancelNotifications(id.hashCode);
    await service.deleteSchedule(id);
  }

  List<Circuit> getCircuits() {
    return CircuitRepository.circuits;
  }

  List<String> getScheduleTypes() {
    return service.getScheduleTypes();
  }

  Circuit? getCircuitById(String circuitId) {
    return CircuitRepository.getCircuitById(circuitId);
  }

  String formatDateTime(BuildContext context, DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}