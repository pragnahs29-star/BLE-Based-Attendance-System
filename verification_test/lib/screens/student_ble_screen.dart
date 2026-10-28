import 'face_check_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dchs_flutter_beacon/dchs_flutter_beacon.dart';
import 'package:permission_handler/permission_handler.dart';

class StudentBleScreen extends StatefulWidget {
  const StudentBleScreen({super.key});

  @override
  State<StudentBleScreen> createState() => _StudentBleScreenState();
}

class _StudentBleScreenState extends State<StudentBleScreen> {
  String detectionMessage = 'Tap to verify classroom presence';
  bool isScanning = false;
  StreamSubscription? _streamRanging;

  Future<void> _scanBeacon() async {
    setState(() {
      isScanning = true;
      detectionMessage = 'Scanning for classroom beacon...';
    });

    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    final regions = <Region>[
      Region(
        identifier: 'ClassroomRegion',
        proximityUUID: 'CB10023F-A313-4670-B125-566C07361B22',
      ),
    ];

    bool found = false;

    _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) async {
      if (result.beacons.isNotEmpty && !found) {
        found = true;
        _streamRanging?.cancel();

        setState(() {
          detectionMessage = 'Classroom detected! Proceeding to face verification...';
          isScanning = false;
        });

        final bool? faceVerified = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => FaceCheckScreen()),
        );

        if (mounted) {
          setState(() {
            if (faceVerified == true) {
              detectionMessage = 'Attendance Verified Successfully!';
            } else {
              detectionMessage = 'Face verification failed or canceled.';
            }
          });
        }
      }
    });

    Timer(const Duration(seconds: 10), () {
      if (!found && mounted) {
        _streamRanging?.cancel();
        setState(() {
          detectionMessage = 'Move closer to the classroom beacon';
          isScanning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _streamRanging?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Attendance Verification')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                detectionMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: detectionMessage.contains('Successfully')
                      ? Colors.green
                      : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 25),
            isScanning
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _scanBeacon,
                    child: const Text('Verify Presence & Attendance'),
                  ),
          ],
        ),
      ),
    );
  }
}