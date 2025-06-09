// test/schedule_presenter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tpm_fp/models/schedule_model.dart';
import 'package:tpm_fp/presenters/schedule_presenter.dart';
import 'package:tpm_fp/network/schedule_service.dart';

import 'mocks/mock_notifs_test.mocks.dart';

class FakeScheduleService extends Fake implements ScheduleService {
  @override
  Future<void> saveSchedule(Schedule schedule) async {}
}

void main() {
  group('SchedulePresenter - scheduleRaceNotifications', () {
    late SchedulePresenter presenter;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockNotificationService = MockNotificationService();
      presenter = SchedulePresenter();
      presenter
        ..notificationService = mockNotificationService
        ..service = FakeScheduleService();
    });

    test('Should call scheduleRaceNotifications when notificationEnabled is true', () async {
      final schedule = Schedule(
        id: 'test123',
        name: 'Test Race',
        circuitId: 'testCircuit',
        type: 'Main Race',
        dateTime: DateTime.now().add(Duration(hours: 2)),
        notificationEnabled: true,
        createdAt: DateTime.now(),
      );

      await presenter.saveSchedule(
        name: schedule.name,
        circuitId: schedule.circuitId,
        type: schedule.type,
        dateTime: schedule.dateTime,
        notificationEnabled: true,
      );

      verify(mockNotificationService.scheduleRaceNotifications(any)).called(1);
    });

    test('Should NOT call scheduleRaceNotifications when notificationEnabled is false', () async {
      final schedule = Schedule(
        id: 'test123',
        name: 'Test Race',
        circuitId: 'testCircuit',
        type: 'Main Race',
        dateTime: DateTime.now().add(Duration(hours: 2)),
        notificationEnabled: false,
        createdAt: DateTime.now(),
      );

      await presenter.saveSchedule(
        name: schedule.name,
        circuitId: schedule.circuitId,
        type: schedule.type,
        dateTime: schedule.dateTime,
        notificationEnabled: false,
      );

      verifyNever(mockNotificationService.scheduleRaceNotifications(any));
    });
  });
}
