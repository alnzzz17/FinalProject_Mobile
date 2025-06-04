import 'package:geolocator/geolocator.dart';
import 'package:tpm_fp/models/data/circuit_data.dart';
import 'package:tpm_fp/models/circuit_model.dart';

class MapPresenter {
  // Use the circuits from CircuitRepository
  List<Circuit> get circuits => CircuitRepository.circuits;

  MapPresenter();

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  List<Circuit> getNearbyCircuits(Position userPosition, [double radiusKm = 100]) {
    return circuits.where((circuit) {
      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        circuit.latitude,
        circuit.longitude,
      );
      return distance <= radiusKm * 1000;
    }).toList();
  }
}