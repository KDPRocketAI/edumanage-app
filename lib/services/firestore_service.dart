import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Real-time stream of the current user's schoolId
  Stream<String?> get schoolIdStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data()?['schoolId'] as String?);
  }

  // Get all classes for a school
  Stream<QuerySnapshot> getClasses(String schoolId) {
    return _db
        .collection('classes')
        .where('schoolId', isEqualTo: schoolId)
        .snapshots();
  }

  // Get all students for a school
  Stream<QuerySnapshot> getStudents(String schoolId) {
    return _db
        .collection('students')
        .where('schoolId', isEqualTo: schoolId)
        .snapshots();
  }

  // Get students of a specific class
  Stream<QuerySnapshot> getStudentsByClass(String schoolId, String className) {
    return _db
        .collection('students')
        .where('schoolId', isEqualTo: schoolId)
        .where('class', isEqualTo: className)
        .snapshots();
  }

  // Get all teachers for a school (from users collection)
  Stream<QuerySnapshot> getTeachers(String schoolId) {
    return _db
        .collection('users')
        .where('schoolId', isEqualTo: schoolId)
        .where('role', isEqualTo: 'teacher')
        .snapshots();
  }

  // Get attendance records for a specific date
  Stream<QuerySnapshot> getAttendanceForDate(String schoolId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return _db
        .collection('attendance')
        .where('schoolId', isEqualTo: schoolId)
        .where('date', isEqualTo: Timestamp.fromDate(startOfDay))
        .snapshots();
  }

  // Save attendance
  Future<void> saveAttendance({
    required String schoolId,
    required String className,
    required DateTime date,
    required List<Map<String, dynamic>> records,
  }) async {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final docId = "${schoolId}_${className}_$dateStr";

    await _db.collection('attendance').doc(docId).set({
      'schoolId': schoolId,
      'class': className,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'records': records,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
