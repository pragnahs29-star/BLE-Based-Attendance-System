import 'dart:async';
import 'package:dchs_flutter_beacon/dchs_flutter_beacon.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  StreamSubscription? _rangingSubscription;

  /// Requests necessary Bluetooth and Location permissions
  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  /// Scans for the classroom beacon with a given UUID within the timeout duration
  Future<bool> scanForBeacon({
    required String uuid,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final hasPermissions = await requestPermissions();
    if (!hasPermissions) return false;

    final Completer<bool> completer = Completer<bool>();
    final regions = <Region>[
      Region(
        identifier: 'ClassroomRegion',
        proximityUUID: uuid,
      ),
    ];

    _rangingSubscription = flutterBeacon.ranging(regions).listen((RangingResult result) {
      if (result.beacons.isNotEmpty && !completer.isCompleted) {
        _stopScanning();
        completer.complete(true);
      }
    });

    // Handle timeout if no beacon is found within the specified time
    Timer(timeout, () {
      if (!completer.isCompleted) {
        _stopScanning();
        completer.complete(false);
      }
    });

    return completer.future;
  }

  void _stopScanning() {
    _rangingSubscription?.cancel();
    _rangingSubscription = null;
  }

  void dispose() {
    _stopScanning();
  }
}