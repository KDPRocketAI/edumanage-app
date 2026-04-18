import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/admin_dashboard.dart';
import '../screens/students_grid.dart';
import '../screens/teachers_list.dart';
import '../screens/attendance_screen.dart';
import '../screens/homework_screen.dart';
import '../screens/notices_screen.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNav({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget targetScreen;
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
          (route) => false,
        );
        return;
      case 1:
        targetScreen = const StudentsGrid();
        break;
      case 2:
        targetScreen = const TeachersList();
        break;
      case 3:
        targetScreen = const AttendanceScreen();
        break;
      case 4:
        targetScreen = const HomeworkScreen();
        break;
      case 5:
        targetScreen = const NoticesScreen();
        break;
      default:
        targetScreen = const AdminDashboard();
    }

    debugPrint("Bottom Nav: Tapped index $index");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              _buildNavItem(context, Icons.dashboard_rounded, 'Dashboard', 0),
              _buildNavItem(context, Icons.people_alt_rounded, 'Students', 1),
              _buildNavItem(context, Icons.school_rounded, 'Teachers', 2),
              _buildNavItem(context, Icons.check_circle_rounded, 'Attendance', 3),
              _buildNavItem(context, Icons.book_rounded, 'Homework', 4),
              _buildNavItem(context, Icons.campaign_rounded, 'Notices', 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    bool selected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(context, index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE8F0FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? const Color(0xFF1A3A8F) : Colors.black38,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
              style: GoogleFonts.manrope(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? const Color(0xFF1A3A8F) : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
