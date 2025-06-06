import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tpm_fp/views/widgets/compass_widget.dart';
import 'package:tpm_fp/presenters/compass_presenter.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  final CompassPresenter _presenter = CompassPresenter();
  double? _heading;
  bool _hasPermissions = false;
  bool _isLoading = true;
  bool _needsCalibration = false;

  Timer? _calibrationTimer;

  @override
  void dispose() {
    _calibrationTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initCompass();
  }

  Future<void> _initCompass() async {
    setState(() => _isLoading = true);
    
    try {
      final hasPermissions = await _presenter.checkPermissions();
      setState(() {
        _hasPermissions = hasPermissions;
        _isLoading = false;
      });

      if (hasPermissions) {
        _presenter.compassStream.listen((heading) {
          if (mounted) {
            setState(() => _heading = heading);
          }
        });

        // Listen for compass accuracy status
        _presenter.accuracyStream.listen((isAccurate) {
          if (mounted) {
            setState(() {
              _needsCalibration = isAccurate == false;

              // If compass becomes accurate, set timer to hide notification
              if (isAccurate == true) {
                _calibrationTimer?.cancel();
                _calibrationTimer = Timer(const Duration(seconds: 5), () {
                  if (mounted) {
                    setState(() => _needsCalibration = false);
                  }
                });
              }
            });
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize compass: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 1)
        
      );
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
          'Compass',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const CircularProgressIndicator(
        color: Colors.red,
      );
    }

    if (!_hasPermissions) {
      return _buildPermissionRequest();
    }

    if (_heading == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Initializing compass...',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _initCompass,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CompassWidget(heading: _heading),
        const SizedBox(height: 20),
        Text(
          '${_heading!.toStringAsFixed(1)}°',
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        if (_needsCalibration)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Compass needs calibration! Move your device in a figure-8 pattern',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() => _needsCalibration = false);
                      },
                      child: const Text(
                        'I have calibrated',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Point your device to see compass direction changes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionRequest() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Location permission is required to use the compass',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initCompass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Request Permission'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _presenter.openAppSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}