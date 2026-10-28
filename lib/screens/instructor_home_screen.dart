import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/attendance_service.dart';
import 'login_screen.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final classNameController = TextEditingController();

  String? activeSessionId;

  Future<void> startSession() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || classNameController.text.trim().isEmpty) return;

    final sessionId = await _attendanceService.createSession(
      className: classNameController.text.trim(),
      instructorId: user.uid,
    );

    setState(() {
      activeSessionId = sessionId;
    });
  }

  Future<void> closeSession() async {
    if (activeSessionId == null) return;

    await _attendanceService.closeSession(activeSessionId!);

    setState(() {
      activeSessionId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: classNameController,
              decoration: const InputDecoration(
                labelText: 'Class Name',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: startSession,
              child: const Text('Start Attendance'),
            ),
            const SizedBox(height: 10),
            if (activeSessionId != null)
              ElevatedButton(
                onPressed: closeSession,
                child: const Text('Close Attendance'),
              ),
            const SizedBox(height: 20),
            if (activeSessionId != null)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('attendance')
                      .where('sessionId', isEqualTo: activeSessionId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('No attendance marked yet'),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data =
                            docs[index].data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(data['studentName'] ?? 'Student'),
                          subtitle: Text(
                            'Roll No: ${data['rollNumber'] ?? '-'}',
                          ),
                          trailing: Text(data['status'] ?? 'PRESENT'),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}