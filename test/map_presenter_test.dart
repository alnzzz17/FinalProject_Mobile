import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tpm_fp/presenters/map_presenter.dart';

void main() {
  group('MapPresenter.getNearbyCircuits()', () {
    late MapPresenter presenter;

    setUp(() {
      presenter = MapPresenter();
    });

    test('Returns nearby circuits within 100km of Mandalika (Indonesia)', () {
      // Lokasi user di sekitar Sirkuit Mandalika
      final userPosition = Position(
        latitude: -8.8940,
        longitude: 116.3080,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      );

      final nearbyCircuits = presenter.getNearbyCircuits(userPosition, 100);

      // Harus mengandung Mandalika
      final containsMandalika = nearbyCircuits.any((c) => c.id == 'indonesia');

      expect(containsMandalika, isTrue);

      // Harus tidak mengandung circuit di luar radius 100 km
      final allWithinRange = nearbyCircuits.every((circuit) {
        final dist = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          circuit.latitude,
          circuit.longitude,
        );
        return dist <= 100000; // 100 km dalam meter
      });

      expect(allWithinRange, isTrue);
    });

    test('Returns empty list if no circuit within 1km', () {
      // Lokasi terpencil (tengah Samudra Pasifik)
      final userPosition = Position(
        latitude: 0.0,
        longitude: -160.0,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      );

      final nearbyCircuits = presenter.getNearbyCircuits(userPosition, 1);

      expect(nearbyCircuits, isEmpty);
    });
  });
}
