import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createSession({
    required String className,
    required String instructorId,
  }) async {
    final doc = await _firestore.collection('sessions').add({
      'className': className,
      'instructorId': instructorId,
      'startTime': FieldValue.serverTimestamp(),
      'status': 'active',
      'bleVerifiedRequired': true,
      'faceVerifiedRequired': true,
    });

    return doc.id;
  }

  Future<void> closeSession(String sessionId) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'closed',
    });
  }

  Future<bool> hasAlreadyMarked({
    required String sessionId,
    required String studentId,
  }) async {
    final result = await _firestore
        .collection('attendance')
        .where('sessionId', isEqualTo: sessionId)
        .where('studentId', isEqualTo: studentId)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<void> markAttendance({
    required String sessionId,
    required String studentId,
    required String rollNumber,
    required String studentName,
    required bool bleVerified,
    required bool faceVerified,
  }) async {
    await _firestore.collection('attendance').add({
      'sessionId': sessionId,
      'studentId': studentId,
      'studentName': studentName,
      'rollNumber': rollNumber,
      'status': 'PRESENT',
      'bleVerified': bleVerified,
      'faceVerified': faceVerified,
      'recheckStatus': 'PENDING',
      'checkInTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRecheckResult({
    required String attendanceId,
    required String recheckStatus,
  }) async {
    await _firestore.collection('attendance').doc(attendanceId).update({
      'recheckStatus': recheckStatus,
      'status': recheckStatus == 'PASSED' ? 'PRESENT' : 'FLAGGED',
    });
  }
}