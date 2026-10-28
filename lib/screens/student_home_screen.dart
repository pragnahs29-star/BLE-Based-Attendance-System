import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/attendance_service.dart';
import 'login_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final AttendanceService _attendanceService = AttendanceService();

  Future<void> markAttendance(String sessionId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data();

    final alreadyMarked = await _attendanceService.hasAlreadyMarked(
      sessionId: sessionId,
      studentId: user.uid,
    );

    if (alreadyMarked) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance already marked')),
      );
      return;
    }

    // Integration points for BLE & face verification modules
    bool bleVerified = false;
    bool faceVerified = false;

    await _attendanceService.markAttendance(
      sessionId: sessionId,
      studentId: user.uid,
      rollNumber: userData?['rollNumber'] ?? '',
      studentName: userData?['name'] ?? '',
      bleVerified: bleVerified,
      faceVerified: faceVerified,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance marked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .where('status', isEqualTo: 'active')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data!.docs;

          if (sessions.isEmpty) {
            return const Center(
              child: Text('No active attendance session'),
            );
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final data = session.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['className'] ?? 'Class'),
                  subtitle: const Text('Attendance is active'),
                  trailing: ElevatedButton(
                    onPressed: () => markAttendance(session.id),
                    child: const Text('Mark'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}