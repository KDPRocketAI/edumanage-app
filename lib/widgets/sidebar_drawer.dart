import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../screens/admin_dashboard.dart';
import '../screens/students_grid.dart';
import '../screens/teachers_list.dart';
import '../screens/attendance_screen.dart';
import '../screens/homework_screen.dart';
import '../screens/notices_screen.dart';
import '../screens/how_to_use_screen.dart';

class SidebarDrawer extends StatelessWidget {
  final String currentRoute;

  const SidebarDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildDrawerUserSection(),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerItem(context, Icons.dashboard_rounded, 'Dashboard', 'dashboard', const AdminDashboard()),
                  _buildDrawerItem(context, Icons.people_alt_rounded, 'Students', 'students', const StudentsGrid()),
                  _buildDrawerItem(context, Icons.school_rounded, 'Teachers', 'teachers', const TeachersList()),
                  _buildDrawerItem(context, Icons.check_circle_rounded, 'Attendance', 'attendance', const AttendanceScreen()),
                  _buildDrawerItem(context, Icons.menu_book_rounded, 'Homework', 'homework', const HomeworkScreen()),
                  _buildDrawerItem(context, Icons.campaign_rounded, 'Notices', 'notices', const NoticesScreen()),
                  _buildDrawerItem(context, Icons.help_outline_rounded, 'How to Use', 'how_to_use', const HowToUseScreen()),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: Text(
                'Logout',
                style: GoogleFonts.manrope(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                authService.signOut();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerUserSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'A',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF1A3A8F),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                'admin',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String label, String route, Widget screen) {
    bool selected = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: selected ? const Color(0xFFE8F0FF) : Colors.transparent,
        leading: Icon(
          icon,
          color: selected ? const Color(0xFF1A3A8F) : Colors.black54,
          size: 22,
        ),
        title: Text(
          label,
          style: GoogleFonts.manrope(
            color: selected ? const Color(0xFF1A3A8F) : Colors.black87,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: () {
          debugPrint("Navigating to $label from $currentRoute");
          Navigator.pop(context);
          if (!selected) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          }
        },
      ),
    );
  }
}
