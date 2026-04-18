import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/version_check_service.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/custom_bottom_nav.dart';
import 'students_grid.dart';
import 'teachers_list.dart';
import 'attendance_screen.dart';
import 'add_student_screen.dart';
import 'add_teacher_screen.dart';
import 'add_class_screen.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Check for updates on dashboard load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VersionCheckService().checkVersion(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
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
          return const Scaffold(body: Center(child: Text('Unauthorized')));
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8F9FA),
          drawer: const SidebarDrawer(currentRoute: 'dashboard'),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 16),
                  _buildWelcomeCard(),
                  const SizedBox(height: 24),
                  _buildSchoolActivityOverview(schoolId),
                  const SizedBox(height: 16),
                  _buildSummaryGrid(schoolId),
                  const SizedBox(height: 24),
                  _buildSectionLabel('QUICK ACTIONS'),
                  const SizedBox(height: 12),
                  _buildQuickActions(schoolId),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const CustomBottomNav(selectedIndex: 0),
        );
      },
    );
  }

  Widget _buildSchoolActivityOverview(String schoolId) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAttendanceForDate(schoolId, DateTime.now()),
      builder: (context, attendanceSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getStudents(schoolId),
          builder: (context, studentsSnapshot) {
            final totalStudents = studentsSnapshot.data?.docs.length ?? 0;
            final attendanceDocs = attendanceSnapshot.data?.docs ?? [];
            
            int present = 0;
            int absent = 0;
            int leave = 0;

            for (var doc in attendanceDocs) {
              final records = (doc.data() as Map<String, dynamic>)['records'] as List? ?? [];
              for (var r in records) {
                if (r['status'] == 1) present++;
                else if (r['status'] == 2) absent++;
                else if (r['status'] == 3) leave++;
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('School Activity Overview', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('Real-time insights for $todayStr', style: GoogleFonts.manrope(fontSize: 12, color: Colors.black45)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActivityStat('$totalStudents', 'STUDENTS', Colors.blue),
                        _buildActivityStat('$present', 'PRESENT', Colors.green),
                        _buildActivityStat('$absent', 'ABSENT', Colors.red),
                        _buildActivityStat('$leave', 'LEAVE', Colors.orange),
                      ],
                    ),
                    const Divider(height: 40),
                    _buildActivityRow(Icons.book_outlined, 'Academic Activity', 'Homework', 'GIVEN: 0 · PENDING: 0', Colors.purple),
                    const SizedBox(height: 16),
                    _buildActivityRow(Icons.campaign_outlined, 'Communication', 'Notices', 'TODAY: 0 · ACTIVE: 2', Colors.pink),
                    const SizedBox(height: 20),
                    _buildSystemStatus(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryGrid(String schoolId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getStudents(schoolId),
      builder: (context, studentsSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getTeachers(schoolId),
          builder: (context, teachersSnap) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryCard('${studentsSnap.data?.docs.length ?? 0}', 'TOTAL STUDENTS', Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('${teachersSnap.data?.docs.length ?? 0}', 'TEACHERS', Colors.green)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(String schoolId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildActionButton('Add Class', Icons.class_outlined, Colors.indigoAccent, () {
            debugPrint("Add Class clicked");
            _navigateTo(AddClassScreen(schoolId: schoolId));
          }),
          const SizedBox(height: 12),
          _buildActionButton('Add Teacher', Icons.person_add_outlined, Colors.indigoAccent, () {
            debugPrint("Add Teacher clicked");
            _navigateTo(AddTeacherScreen(schoolId: schoolId));
          }),
          const SizedBox(height: 12),
          _buildActionButton('Add Student', Icons.school_outlined, Colors.indigoAccent, () {
            debugPrint("Add Student clicked");
            _navigateTo(AddStudentScreen(schoolId: schoolId));
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B8FF7),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildActivityStat(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
        Text(label, style: GoogleFonts.manrope(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _buildActivityRow(IconData icon, String title, String tag, String sub, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700)),
              Text(sub, style: GoogleFonts.manrope(fontSize: 11, color: Colors.black45)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
          child: Text(tag, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
        ),
      ],
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('All Systems Normal', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.green)),
              Text('No critical issues found today.', style: GoogleFonts.manrope(fontSize: 11, color: Colors.green.withOpacity(0.7))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.menu_rounded, size: 26), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
          Text('Dashboard', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.power_settings_new, size: 22, color: Colors.black87), onPressed: () => _authService.signOut()),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome ABC', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800)),
                Text('EduManage • Dashboard', style: GoogleFonts.manrope(fontSize: 14, color: Colors.black45)),
              ],
            ),
            const Spacer(),
            Image.network('https://cdn-icons-png.flaticon.com/512/3652/3652191.png', width: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(label, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black45, letterSpacing: 1.1)));
  }
}
