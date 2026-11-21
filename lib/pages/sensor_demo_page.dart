
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorDemoPage extends StatefulWidget {
  const SensorDemoPage({super.key});

  @override
  State<SensorDemoPage> createState() => _SensorDemoPageState();
}

class _SensorDemoPageState extends State<SensorDemoPage> {
  StreamSubscription<UserAccelerometerEvent>? _subscription;

  double _x = 0;
  double _y = 0;
  double _z = 0;

  bool _hasReading = false;

  static const double _smoothing = 0.15;
  static const double _deadZone = 0.08;

  @override
  void initState() {
    super.initState();

    _subscription = userAccelerometerEventStream().listen(
      (event) {
        if (!mounted) return;

        setState(() {
          if (!_hasReading) {
            _x = event.x;
            _y = event.y;
            _z = event.z;
            _hasReading = true;
          } else {
            _x = _filter(_x, event.x);
            _y = _filter(_y, event.y);
            _z = _filter(_z, event.z);
          }
        });
      },
      onError: (Object error) {
        if (mounted) {
          setState(() => _hasReading = false);
        }
      },
      cancelOnError: true,
    );
  }

  double _filter(double previous, double current) {
    final difference = current - previous;

    if (difference.abs() < _deadZone) {
      return previous;
    }

    return previous + difference * _smoothing;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Accelerometer'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sensors,
                size: 60,
              ),
              const SizedBox(height: 20),
              const Text(
                'Data Accelerometer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (_hasReading) ...[
                _sensorValue('X', _x),
                _sensorValue('Y', _y),
                _sensorValue('Z', _z),
              ] else
                const Text('Menunggu data sensor...'),
              const SizedBox(height: 20),
              const Text(
                'Gerakkan ponsel perlahan untuk melihat '
                'perubahan nilai sensor.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sensorValue(String axis, double value) {
    return Card(
      child: ListTile(
        title: Text('Sumbu $axis'),
        trailing: Text(
          '${value.toStringAsFixed(2)} m/s²',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
