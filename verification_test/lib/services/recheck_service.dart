import 'package:flutter/material.dart';
import '../screens/recheck_screen.dart';

class RecheckService {
  /// Launches the random recheck screen and awaits user identity confirmation
  Future<String> runRandomRecheck(BuildContext context) async {
    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const RecheckScreen()),
    );
    return result ?? 'FAILED';
  }
}