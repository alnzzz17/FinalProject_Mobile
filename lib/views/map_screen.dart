import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tpm_fp/models/circuit_model.dart';
import 'package:tpm_fp/presenters/map_presenter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapPresenter _presenter = MapPresenter();

  Position? _userPosition;
  List<Circuit> _nearbyCircuits = [];
  bool _isLoading = true;
  bool _showUserLocation = true;
  bool _showCircuits = true;
  double _zoomLevel = 5.0;
  LatLng? _mapCenter;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
  setState(() => _isLoading = true);

  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Disabled',
        'Please turn on your location services.',
        backgroundColor: Colors.orange[800],
        colorText: Colors.white,
      );
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission Denied',
          'Location permission is required to show nearby circuits.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Permanently Denied',
        'Please enable location permission from app settings.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() => _isLoading = false);
      return;
    }

    final position = await _presenter.getCurrentLocation();
    if (position != null) {
      final nearbyCircuits = _presenter.getNearbyCircuits(position);

      setState(() {
        _userPosition = position;
        _nearbyCircuits = nearbyCircuits;
        _mapCenter = LatLng(position.latitude, position.longitude);
      });

      if (nearbyCircuits.isEmpty) {
        Get.snackbar(
          'Info',
          'No nearby circuits found within 100km',
          backgroundColor: Colors.grey[900],
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Could not determine your location.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    Get.snackbar(
      'Error',
      'Error getting location: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Circuits Map',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserLocation,
          ),
          IconButton(
            icon: Icon(
              _showUserLocation ? Icons.person_pin : Icons.person_outline,
              color: Colors.white,
            ),
            onPressed: () =>
                setState(() => _showUserLocation = !_showUserLocation),
          ),
          IconButton(
            icon: Icon(
              _showCircuits ? Icons.flag : Icons.flag_outlined,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _showCircuits = !_showCircuits),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : _buildMap(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            mini: true,
            heroTag: 'zoom_in',
            backgroundColor: Colors.grey[900],
            onPressed: () {
              setState(() {
                _zoomLevel += 1;
              });
              _mapController.move(_mapController.camera.center, _zoomLevel);
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            heroTag: 'zoom_out',
            backgroundColor: Colors.grey[900],
            onPressed: () {
              setState(() {
                _zoomLevel = _zoomLevel > 1 ? _zoomLevel - 1 : _zoomLevel;
              });
              _mapController.move(_mapController.camera.center, _zoomLevel);
            },
            child: const Icon(Icons.remove, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _mapCenter ?? const LatLng(0, 0),
        initialZoom: _zoomLevel,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.tpm_finalproject',
        ),
        if (_showUserLocation && _userPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point:
                    LatLng(_userPosition!.latitude, _userPosition!.longitude),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        if (_showCircuits)
          MarkerLayer(
            markers: _presenter.circuits.map((circuit) {
              return Marker(
                point: LatLng(circuit.latitude, circuit.longitude),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _showCircuitInfo(circuit),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: _nearbyCircuits.contains(circuit)
                            ? Colors.red
                            : Colors.blue,
                        size: 30,
                      ),
                      Positioned(
                        top: 0,
                        child: Text(
                          circuit.flagEmoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        if (_userPosition != null && _nearbyCircuits.isNotEmpty)
          PolylineLayer(
            polylines: _nearbyCircuits.map((circuit) {
              return Polyline(
                points: [
                  LatLng(_userPosition!.latitude, _userPosition!.longitude),
                  LatLng(circuit.latitude, circuit.longitude),
                ],
                color: Colors.red.withOpacity(0.7),
                strokeWidth: 2,
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showCircuitInfo(Circuit circuit) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: ThemeData.dark(),
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            '${circuit.flagEmoji} ${circuit.name}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location: ${circuit.location}',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Timezone: ${circuit.timezone}',
                style: const TextStyle(color: Colors.white70),
              ),
              if (_userPosition != null)
                Text(
                  'Distance: ${_calculateDistance(_userPosition!, circuit).toStringAsFixed(1)} km',
                  style: const TextStyle(color: Colors.white70),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateDistance(Position userPosition, Circuit circuit) {
    return Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          circuit.latitude,
          circuit.longitude,
        ) /
        1000;
  }
}