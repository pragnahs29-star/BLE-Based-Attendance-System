import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentPhotoTestScreen extends StatefulWidget {
  const StudentPhotoTestScreen({super.key});

  @override
  State<StudentPhotoTestScreen> createState() =>
      _StudentPhotoTestScreenState();
}

class _StudentPhotoTestScreenState extends State<StudentPhotoTestScreen> {
  final TextEditingController _rollNumberController = TextEditingController();

  String? _photoUrl;
  String? _studentName;
  bool _isLoading = false;
  String _statusMessage = 'Enter roll number and load student';

  Future<void> _loadStudent() async {
    final rollNumber = _rollNumberController.text.trim();

    if (rollNumber.isEmpty) {
      setState(() {
        _statusMessage = 'Enter a roll number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading student...';
      _photoUrl = null;
      _studentName = null;
    });

    try {
  print('DEBUG rollNumber = "$rollNumber"');

  final doc = await FirebaseFirestore.instance
      .collection('students')
      .doc(rollNumber)
      .get(const GetOptions(source: Source.server));

  print('DEBUG server doc.exists = ${doc.exists}');
  print('DEBUG server doc.id = ${doc.id}');

  if (doc.exists) {
    print('DEBUG server data = ${doc.data()}');
  }
      final data = doc.data()!;

      setState(() {
        _studentName = data['name'];
        _photoUrl = data['photoUrl'];
        _statusMessage = 'Student loaded successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load Student Photo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _rollNumberController,
              decoration: const InputDecoration(
                labelText: 'Enter Roll Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _loadStudent,
              child: const Text('Load Student'),
            ),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_studentName != null)
              Text(
                'Name: $_studentName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            if (_photoUrl != null)
              Expanded(
                child: Image.network(
                  _photoUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Could not load photo');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}