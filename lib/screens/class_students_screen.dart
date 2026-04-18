import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../widgets/sidebar_drawer.dart';
import 'edit_student_screen.dart';

class ClassStudentsScreen extends StatefulWidget {
  final String schoolId;
  final String className;

  const ClassStudentsScreen({
    super.key,
    required this.schoolId,
    required this.className,
  });

  @override
  State<ClassStudentsScreen> createState() => _ClassStudentsScreenState();
}

class _ClassStudentsScreenState extends State<ClassStudentsScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _deleteStudent(String? studentId, String name) async {
    if (studentId == null || studentId.isEmpty) {
      debugPrint('Delete error: studentId is null or empty');
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    debugPrint('Delete clicked: $studentId');
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .delete();
      
      debugPrint('Delete success');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Delete error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF0F0F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'Students',
          style: GoogleFonts.manrope(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _authService.signOut(),
            icon: const Icon(Icons.power_settings_new, color: Colors.black87),
          ),
        ],
      ),
      drawer: const SidebarDrawer(currentRoute: 'students'),
      body: Column(
        children: [
          _buildBackBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getStudents(widget.schoolId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allDocs = snapshot.data?.docs ?? [];
                
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final dbClass = (data['class']?.toString() ?? '').toLowerCase().trim();
                  return dbClass == widget.className.toLowerCase().trim();
                }).toList();
                
                debugPrint('ClassStudentsScreen: Found ${filteredDocs.length} students for ${widget.className}');

                if (filteredDocs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final studentId = doc.id;
                    return _buildStudentCard(studentId, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    'Back',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            '${widget.className} • Students',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(String studentId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF4A90E2), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['name']?.toString() ?? 'Unknown',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'STUDENT',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Roll No: ${data['rollNo'] ?? '00'}',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A90E2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.edit, 
                  label: 'Edit', 
                  color: Colors.orange.shade400,
                  onTap: () {
                    debugPrint('Edit clicked: $studentId');
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (_) => EditStudentScreen(
                          studentId: studentId, 
                          studentData: data,
                          schoolId: widget.schoolId,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete, 
                  label: 'Delete', 
                  color: Colors.redAccent,
                  onTap: () => _deleteStudent(studentId, data['name'] ?? 'Student'),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PARENT',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['parentName']?.toString() ?? 'N/A',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHONE',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['parentPhone']?.toString() ?? 'N/A',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon, 
    required String label, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: label == 'Delete' ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: label == 'Edit' ? Border.all(color: Colors.black12) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: label == 'Delete' ? Colors.white : color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: label == 'Delete' ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_off_outlined, size: 64, color: Colors.black12),
          const SizedBox(height: 16),
          Text(
            'No students found in this class',
            style: GoogleFonts.manrope(
              color: Colors.black38,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
