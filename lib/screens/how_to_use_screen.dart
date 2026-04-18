import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/auth_service.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF0F0F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'How to Use',
          style: GoogleFonts.manrope(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.power_settings_new, color: Colors.black87),
          ),
        ],
      ),
      drawer: const SidebarDrawer(currentRoute: 'how_to_use'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Admin Dashboard'),
            _buildInstructionText('1. View overall school statistics like total students and attendance.'),
            _buildInstructionText('2. Use "Quick Actions" to add Classes, Teachers, or Students.'),
            const SizedBox(height: 20),
            _buildSectionTitle('Managing Students'),
            _buildInstructionText('1. Go to "Students" tab to view classes.'),
            _buildInstructionText('2. Click a class to see students and manage them.'),
            _buildInstructionText('3. Use "Add Student" to enroll new students.'),
            const SizedBox(height: 20),
            _buildSectionTitle('Managing Teachers'),
            _buildInstructionText('1. Go to "Teachers" tab to view staff list.'),
            _buildInstructionText('2. Use "Add Teacher" to register new staff.'),
            _buildInstructionText('3. Click a teacher to view/edit profile.'),
            const SizedBox(height: 20),
            _buildSectionTitle('Attendance'),
            _buildInstructionText('1. Go to "Attendance" tab.'),
            _buildInstructionText('2. Select a class to mark attendance for today.'),
            _buildInstructionText('3. View status summary for each class.'),
            const SizedBox(height: 20),
            _buildSectionTitle('Homework & Notices'),
            _buildInstructionText('1. View latest homework and school-wide notices in real-time.'),
            _buildInstructionText('2. Delete old records using the trash icon.'),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(selectedIndex: -1), // No bottom tab for this help screen
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  Widget _buildInstructionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 14,
          color: Colors.black54,
          height: 1.5,
        ),
      ),
    );
  }
}
