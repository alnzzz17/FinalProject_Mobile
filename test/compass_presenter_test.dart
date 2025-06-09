import 'package:flutter_test/flutter_test.dart';
import 'package:tpm_fp/presenters/compass_presenter.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:async';

import 'mocks/mock_compass.mocks.dart';

void main() {
  group('CompassPresenter Accuracy Stream', () {
    late StreamController<CompassEvent> controller;
    late CompassPresenter presenter;

    setUp(() {
      controller = StreamController<CompassEvent>();
      presenter = CompassPresenter(eventStream: controller.stream);
    });

    tearDown(() async {
      await controller.close();
    });

    test('returns false when accuracy is null', () async {
      final mockEvent = MockCompassEvent();
      when(mockEvent.accuracy).thenReturn(null);

      final result = expectLater(presenter.accuracyStream, emits(false));
      controller.add(mockEvent);
      await result;
    });

    test('returns true when accuracy < 30', () async {
      final mockEvent = MockCompassEvent();
      when(mockEvent.accuracy).thenReturn(15.0);

      final result = expectLater(presenter.accuracyStream, emits(true));
      controller.add(mockEvent);
      await result;
    });

    test('returns false when accuracy > 30', () async {
      final mockEvent = MockCompassEvent();
      when(mockEvent.accuracy).thenReturn(42.0);

      final result = expectLater(presenter.accuracyStream, emits(false));
      controller.add(mockEvent);
      await result;
    });
  });
}
