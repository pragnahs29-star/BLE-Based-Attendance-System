import 'package:flutter/material.dart';
import 'package:dchs_flutter_beacon/dchs_flutter_beacon.dart';
import 'package:permission_handler/permission_handler.dart';

class InstructorBeaconScreen extends StatefulWidget {
  const InstructorBeaconScreen({super.key});

  @override
  State<InstructorBeaconScreen> createState() => _InstructorBeaconScreenState();
}

class _InstructorBeaconScreenState extends State<InstructorBeaconScreen> {
  bool isAdvertising = false;
  String status = 'Beacon not started';
  final String sessionId = "ATTEND-CLASS-01";

  Future<void> _toggleBeacon() async {
    if (isAdvertising) {
      await flutterBeacon.stopBroadcast();
      setState(() {
        isAdvertising = false;
        status = 'Beacon stopped';
      });
      return;
    }

    await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    try {
      await flutterBeacon.startBroadcast(BeaconBroadcast(
        proximityUUID: 'CB10023F-A313-4670-B125-566C07361B22',
        major: 1,
        minor: 1,
      ));
      setState(() {
        isAdvertising = true;
        status = 'Beacon running for Session: $sessionId';
      });
    } catch (e) {
      setState(() => status = 'Broadcast error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instructor Beacon Broadcast')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleBeacon,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdvertising ? Colors.red : Colors.green,
              ),
              child: Text(isAdvertising ? 'Stop Classroom Beacon' : 'Start Classroom Beacon'),
            ),
          ],
        ),
      ),
    );
  }
}