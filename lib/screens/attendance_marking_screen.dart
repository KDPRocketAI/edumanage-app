import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class AttendanceMarkingScreen extends StatefulWidget {
  final String schoolId;
  final String className;

  const AttendanceMarkingScreen({
    super.key,
    required this.schoolId,
    required this.className,
  });

  @override
  State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  final _firestoreService = FirestoreService();
  final Map<String, int> _attendanceStatus = {};

  Future<void> _saveAttendance(List<DocumentSnapshot> students) async {
    final notMarked = students.where((s) => (_attendanceStatus[s.id] ?? 0) == 0).length;
    
    if (notMarked > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$notMarked students not marked yet!')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final records = students.map((s) => {
        'studentId': s.id,
        'name': (s.data() as Map<String, dynamic>)['name'],
        'rollNo': (s.data() as Map<String, dynamic>)['rollNo'],
        'status': _attendanceStatus[s.id] ?? 0,
      }).toList();

      await _firestoreService.saveAttendance(
        schoolId: widget.schoolId,
        className: widget.className,
        date: _selectedDate,
        records: records,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text('${widget.className} Attendance', style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black87)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getStudentsByClass(widget.schoolId, widget.className),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final students = snapshot.data?.docs ?? [];
          for (var doc in students) {
            _attendanceStatus.putIfAbsent(doc.id, () => 0);
          }

          if (students.isEmpty) return const Center(child: Text('No students in this class'));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, i) => _buildStudentTile(students[i]),
                ),
              ),
              _buildBottomAction(() => _saveAttendance(students)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudentTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final status = _attendanceStatus[id] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFF0F0F7), child: Text(data['rollNo'] ?? '0', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(child: Text(data['name'] ?? 'Unknown', style: GoogleFonts.manrope(fontWeight: FontWeight.w600))),
          Row(
            children: [
              _statusBtn(1, Colors.green, Icons.check, status == 1, () => setState(() => _attendanceStatus[id] = 1)),
              const SizedBox(width: 8),
              _statusBtn(2, Colors.red, Icons.close, status == 2, () => setState(() => _attendanceStatus[id] = 2)),
              const SizedBox(width: 8),
              _statusBtn(3, Colors.orange, Icons.timer, status == 3, () => setState(() => _attendanceStatus[id] = 3)),
            ],
          )
        ],
      ),
    );
  }

  Widget _statusBtn(int val, Color color, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: selected ? color : color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: selected ? Colors.white : color),
      ),
    );
  }

  Widget _buildBottomAction(VoidCallback onSave) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isSaving ? null : onSave,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8D4B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Attendance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
