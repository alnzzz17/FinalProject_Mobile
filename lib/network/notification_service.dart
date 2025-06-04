import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:tpm_fp/models/circuit_model.dart';
import 'package:tpm_fp/models/schedule_model.dart';
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    // Initialize workmanager for background tasks
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  // Callback for background tasks
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      final notificationService = NotificationService();
      await notificationService._showScheduledNotification(
        id: inputData?['id'] as int,
        title: inputData?['title'] as String,
        body: inputData?['body'] as String,
      );
      return true;
    });
  }

  List<Circuit> circuits = [];

  // Method untuk set circuits
  void setCircuits(List<Circuit> circuits) {
    this.circuits = circuits;
  }

  // Helper method untuk mendapatkan nama circuit
  String _getCircuitName(String circuitId) {
    final circuit = circuits.firstWhere(
      (c) => c.id == circuitId,
      orElse: () => Circuit(
        id: '',
        name: 'Unknown Circuit',
        location: '',
        timezone: '',
        flagEmoji: '',
        latitude: 0,
        longitude: 0,
        currency: '',
      ),
    );
    return circuit.name;
  }

  Future<void> scheduleRaceNotifications(Schedule schedule) async {
    if (!schedule.notificationEnabled) return;

    final raceTime = schedule.dateTime;

     // Get circuit name using the helper method
    final circuitName = _getCircuitName(schedule.circuitId);

    // Schedule notifications
    await _scheduleBackgroundNotification(
      id: schedule.id.hashCode + 1,
      title: '1 Day Reminder: ${schedule.name}',
      body: '${schedule.type} at $circuitName starts tomorrow!',
      scheduledDate: raceTime.subtract(const Duration(days: 1)),
    );

    await _scheduleBackgroundNotification(
      id: schedule.id.hashCode + 2,
      title: '1 Hour Reminder: ${schedule.name}',
      body: '${schedule.type} at $circuitName starts in 1 hour!',
      scheduledDate: raceTime.subtract(const Duration(hours: 1)),
    );

    await _scheduleBackgroundNotification(
      id: schedule.id.hashCode + 3,
      title: '30 Minutes Reminder: ${schedule.name}',
      body: '${schedule.type} at $circuitName starts in 30 minutes!',
      scheduledDate: raceTime.subtract(const Duration(minutes: 30)),
    );

    await _scheduleBackgroundNotification(
      id: schedule.id.hashCode + 4,
      title: '15 Minutes Reminder: ${schedule.name}',
      body: '${schedule.type} at $circuitName starts in 15 minutes!',
      scheduledDate: raceTime.subtract(const Duration(minutes: 15)),
    );

    await _scheduleBackgroundNotification(
      id: schedule.id.hashCode + 5,
      title: '5 Minutes Reminder: ${schedule.name}',
      body: '${schedule.type} at $circuitName starts in 5 minutes!',
      scheduledDate: raceTime.subtract(const Duration(minutes: 5)),
    );

    await _scheduleBackgroundNotification(
      id: schedule.id.hashCode + 6,
      title: 'Race Reminder: ${schedule.name}',
      body: '${schedule.type} at $circuitName starts in now!',
      scheduledDate: raceTime.subtract(const Duration(minutes: 0)),
    );
  }

  Future<void> _scheduleBackgroundNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    // Schedule background task using Workmanager
    await Workmanager().registerOneOffTask(
      '$id',
      'show_notification_$id',
      inputData: {
        'id': id,
        'title': title,
        'body': body,
      },
      initialDelay: scheduledDate.difference(DateTime.now()),
    );

    // Schedule local notification as fallback
    await _scheduleLocalNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }
Future<void> cancelNotifications(int baseId) async {
  // Cancel all related notifications (baseId + 1 to baseId + 6)
  for (int i = 1; i <= 6; i++) {
    await _notificationsPlugin.cancel(baseId + i);
    await Workmanager().cancelByTag('${baseId + i}');
  }
}

  Future<void> _scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'race_reminders',
      'Race Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  Future<void> _showScheduledNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'race_reminders',
      'Race Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
