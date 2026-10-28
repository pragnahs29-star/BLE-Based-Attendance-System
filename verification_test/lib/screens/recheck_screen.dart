import 'package:flutter/material.dart';

class RecheckScreen extends StatelessWidget {
  const RecheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Random Recheck')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Verification Recheck Required'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'SUCCESS'),
              child: const Text('Confirm Identity'),
            ),
          ],
        ),
      ),
    );
  }
}