import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded,        label: 'Home'),
    _NavItem(icon: Icons.bar_chart_rounded,   label: 'Progress'),
    _NavItem(icon: Icons.check_circle_rounded,label: 'Attendance'),
    _NavItem(icon: Icons.campaign_rounded,    label: 'Notices'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 16),
              _buildChildCard(),
              const SizedBox(height: 20),
              _buildTodayAttendance(),
              const SizedBox(height: 20),
              _buildQuickStats(),
              const SizedBox(height: 20),
              _buildSectionLabel('RECENT NOTICES'),
              const SizedBox(height: 12),
              _buildNoticesList(),
              const SizedBox(height: 20),
              _buildSectionLabel('UPCOMING EXAMS'),
              const SizedBox(height: 12),
              _buildExamsList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Top bar ──────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning! 👋',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: Colors.black45,
                ),
              ),
              Text(
                'Parent Portal',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: Color(0xFF8D4B00),
                  size: 22,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC0392B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/100?img=20',
            ),
          ),
        ],
      ),
    );
  }

  // ── Child card ───────────────────────────────────────────
  Widget _buildChildCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8D4B00), Color(0xFFB15F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'AS',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF8D4B00),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aarav Sharma',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Grade 10A  •  Roll No. 01',
                    style: GoogleFonts.manrope(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'School Code: EDU001',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Today attendance ─────────────────────────────────────
  Widget _buildTodayAttendance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F5F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF006A6A),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Attendance',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aarav is present today',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: const Color(0xFF006A6A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '✓ Present',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF006A6A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick stats ──────────────────────────────────────────
  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.percent_rounded,
              title: 'Attendance',
              value: '94%',
              subtitle: 'This month',
              color: const Color(0xFF006A6A),
              bgColor: const Color(0xFFE0F5F5),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildStatCard(
              icon: Icons.grade_rounded,
              title: 'Avg Grade',
              value: 'A+',
              subtitle: 'Last test',
              color: const Color(0xFF8D4B00),
              bgColor: const Color(0xFFFFF0E0),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildStatCard(
              icon: Icons.assignment_rounded,
              title: 'Homework',
              value: '3',
              subtitle: 'Pending',
              color: const Color(0xFFC0392B),
              bgColor: const Color(0xFFFFEBEB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black45,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ── Notices list ─────────────────────────────────────────
  Widget _buildNoticesList() {
    final notices = [
      {
        'title': 'Annual Sports Day',
        'desc': 'Annual sports day on 15th April. All students must participate.',
        'time': '2h ago',
        'color': 'orange',
      },
      {
        'title': 'Parent-Teacher Meeting',
        'desc': 'PTM scheduled for 20th April. Please confirm your attendance.',
        'time': '1d ago',
        'color': 'teal',
      },
      {
        'title': 'Holiday Notice',
        'desc': 'School will remain closed on 14th April for Baisakhi.',
        'time': '2d ago',
        'color': 'blue',
      },
    ];

    return Column(
      children: notices
          .map((n) => _buildNoticeCard(n))
          .toList(),
    );
  }

  Widget _buildNoticeCard(Map<String, String> notice) {
    final isOrange = notice['color'] == 'orange';
    final isTeal = notice['color'] == 'teal';
    final color = isOrange
        ? const Color(0xFF8D4B00)
        : isTeal
        ? const Color(0xFF006A6A)
        : const Color(0xFF1A3A8F);
    final bgColor = isOrange
        ? const Color(0xFFFFF0E0)
        : isTeal
        ? const Color(0xFFE0F5F5)
        : const Color(0xFFE8F0FF);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.campaign_rounded,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice['title']!,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notice['desc']!,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              notice['time']!,
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Exams list ───────────────────────────────────────────
  Widget _buildExamsList() {
    final exams = [
      {'subject': 'Mathematics', 'date': '18 Apr', 'time': '9:00 AM', 'syllabus': 'Ch 1-5'},
      {'subject': 'Science',     'date': '22 Apr', 'time': '9:00 AM', 'syllabus': 'Ch 3-7'},
      {'subject': 'English',     'date': '25 Apr', 'time': '9:00 AM', 'syllabus': 'Grammar + Essay'},
    ];

    return Column(
      children: exams.map((e) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        e['date']!.split(' ')[0],
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF8D4B00),
                        ),
                      ),
                      Text(
                        e['date']!.split(' ')[1],
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8D4B00),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e['subject']!,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${e['time']}  •  ${e['syllabus']}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Upcoming',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A3A8F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Bottom nav ───────────────────────────────────────────
  Widget _buildBottomNav() {
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final selected = i == _selectedIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFFF0E0)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: selected
                            ? const Color(0xFF8D4B00)
                            : Colors.black38,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? const Color(0xFF8D4B00)
                              : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}