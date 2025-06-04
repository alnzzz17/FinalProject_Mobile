import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

class CompassPresenter {
  Stream<double?> get compassStream =>
      FlutterCompass.events?.map((event) => event.heading) ?? const Stream.empty();

Stream<bool?> get accuracyStream =>
    FlutterCompass.events?.map((event) {
      // If accuracy is null, we cannot determine if it's accurate
      if (event.accuracy == null) return false;
      
      // Use a threshold to determine if the compass is accurate
      return event.accuracy! < 30;
    }) ?? const Stream.empty();

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