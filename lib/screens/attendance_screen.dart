import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/custom_bottom_nav.dart';
import 'attendance_marking_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _firestoreService.schoolIdStream,
      builder: (context, schoolIdSnapshot) {
        if (schoolIdSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final schoolId = schoolIdSnapshot.data;
        if (schoolId == null) return const Scaffold(body: Center(child: Text('Unauthorized')));

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF0F0F7),
          appBar: _buildAppBar(),
          drawer: const SidebarDrawer(currentRoute: 'attendance'),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Text(
                  'Attendance Summary',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getClasses(schoolId),
                  builder: (context, classSnapshot) {
                    if (!classSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final classes = classSnapshot.data!.docs;

                    return StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getAttendanceForDate(schoolId, DateTime.now()),
                      builder: (context, attendanceSnapshot) {
                        final attendanceDocs = attendanceSnapshot.data?.docs ?? [];

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: classes.length,
                          itemBuilder: (context, index) {
                            final classData = classes[index].data() as Map<String, dynamic>;
                            final className = classData['name'] ?? 'Unknown';
                            
                            // Find attendance record for this class
                            final classAttendance = attendanceDocs.where((doc) => doc['class'] == className).firstOrNull;

                            return _buildClassSummaryCard(schoolId, className, classAttendance);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: const CustomBottomNav(selectedIndex: 3),
        );
      },
    );
  }

  Widget _buildClassSummaryCard(String schoolId, String className, DocumentSnapshot? attendanceDoc) {
    Map<String, dynamic>? data = attendanceDoc?.data() as Map<String, dynamic>?;
    List records = data?['records'] ?? [];
    
    int present = records.where((r) => r['status'] == 1).length;
    int absent = records.where((r) => r['status'] == 2).length;
    int leave = records.where((r) => r['status'] == 3).length;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceMarkingScreen(schoolId: schoolId, className: className))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(className, style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87)),
                Text(
                  attendanceDoc == null ? 'No records yet' : 'Updated Today',
                  style: GoogleFonts.manrope(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStatItem('TOTAL', '-', const Color(0xFF6366F1), Icons.group),
                _buildStatItem('PRESENT', '$present', const Color(0xFF10B981), Icons.check_box),
                _buildStatItem('ABSENT', '$absent', const Color(0xFFEF4444), Icons.cancel),
                _buildStatItem('LEAVE', '$leave', const Color(0xFFF59E0B), Icons.description),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              attendanceDoc == null ? 'Waiting for first record...' : 'Click to update attendance',
              style: GoogleFonts.manrope(fontSize: 11, color: Colors.black26, fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: GoogleFonts.manrope(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black38, letterSpacing: 0.5)),
              Text(value, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
            ],
          )
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white, elevation: 0.5,
      leading: IconButton(icon: const Icon(Icons.menu, color: Colors.black87), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
      title: Text('Attendance', style: GoogleFonts.manrope(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 18)),
      actions: [IconButton(onPressed: () => _authService.signOut(), icon: const Icon(Icons.power_settings_new, color: Colors.black87))],
    );
  }
}
