import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

class CompassPresenter {
  final Stream<CompassEvent> _eventStream;

  CompassPresenter({Stream<CompassEvent>? eventStream})
      : _eventStream = eventStream ?? FlutterCompass.events!;

  Stream<double?> get compassStream =>
      _eventStream.map((event) => event.heading);

  Stream<bool?> get accuracyStream =>
      _eventStream.map((event) {
        if (event.accuracy == null) return false;
        return event.accuracy! < 30;
      });

  Future<bool> checkPermissions() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      final result = await Permission.locationWhenInUse.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
