import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/custom_bottom_nav.dart';
import 'class_students_screen.dart';
import 'add_student_screen.dart';

class StudentsGrid extends StatefulWidget {
  const StudentsGrid({super.key});

  @override
  State<StudentsGrid> createState() => _StudentsGridState();
}

class _StudentsGridState extends State<StudentsGrid> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Extract number from class string (e.g., "Class 1" -> 1)
  int _extractClassNumber(String className) {
    final numberMatch = RegExp(r'\d+').firstMatch(className);
    if (numberMatch != null) {
      return int.tryParse(numberMatch.group(0)!) ?? 999;
    }
    return 999; // Put non-numeric at the end
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _firestoreService.schoolIdStream,
      builder: (context, schoolIdSnapshot) {
        if (schoolIdSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final schoolId = schoolIdSnapshot.data;
        if (schoolId == null) {
          return const Scaffold(body: Center(child: Text('Unauthorized or School ID not found')));
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF0F0F7),
          appBar: _buildAppBar(),
          drawer: const SidebarDrawer(currentRoute: 'students'),
          body: Column(
            children: [
              _buildHeaderRow(schoolId),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getClasses(schoolId),
                  builder: (context, classSnapshot) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getStudents(schoolId),
                      builder: (context, studentSnapshot) {
                        if (classSnapshot.connectionState == ConnectionState.waiting ||
                            studentSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        var classDocs = classSnapshot.data?.docs ?? [];
                        final studentDocs = studentSnapshot.data?.docs ?? [];

                        // Numeric Sorting
                        classDocs.sort((a, b) {
                          final nameA = (a.data() as Map<String, dynamic>)['name']?.toString() ?? '';
                          final nameB = (b.data() as Map<String, dynamic>)['name']?.toString() ?? '';
                          return _extractClassNumber(nameA).compareTo(_extractClassNumber(nameB));
                        });

                        // Grouping logic: className -> count (Normalized for Case-Insensitive Matching)
                        final Map<String, int> studentCounts = {};
                        for (var doc in studentDocs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final className = (data['class']?.toString() ?? 'Unassigned').toLowerCase().trim();
                          studentCounts[className] = (studentCounts[className] ?? 0) + 1;
                        }

                        if (classDocs.isEmpty) {
                          return _buildEmptyState();
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: classDocs.length,
                          itemBuilder: (context, index) {
                            final classData = classDocs[index].data() as Map<String, dynamic>;
                            final classNameOriginal = classData['name']?.toString() ?? 'Unknown';
                            final classNameKey = classNameOriginal.toLowerCase().trim();
                            final count = studentCounts[classNameKey] ?? 0;

                            return _buildClassCard(schoolId, classNameOriginal, count);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: const CustomBottomNav(selectedIndex: 1),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildHeaderRow(String schoolId) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Students (By Class)',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddStudentScreen(schoolId: schoolId),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B8FF7),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Add Student',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(String schoolId, String className, int count) {
    final bool isEmpty = count == 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClassStudentsScreen(
              schoolId: schoolId,
              className: className,
            ),
          ),
        );
      },
      child: Container(
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          className,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(Empty)',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: Colors.black38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CLASS ($count STUDENTS)',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: Colors.black45,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.edit_outlined,
                size: 18,
                color: Colors.orange.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, size: 64, color: Colors.black12),
          const SizedBox(height: 16),
          Text(
            'No classes found in Firestore',
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
