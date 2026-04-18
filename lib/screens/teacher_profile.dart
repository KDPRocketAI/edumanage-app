import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherProfile extends StatelessWidget {
  final Map<String, String> teacher;

  const TeacherProfile({super.key, required this.teacher});

  Color _getColor(String color) {
    switch (color) {
      case 'teal':
        return const Color(0xFF006A6A);
      case 'blue':
        return const Color(0xFF1A3A8F);
      case 'pink':
        return const Color(0xFFC2185B);
      default:
        return const Color(0xFF8D4B00);
    }
  }

  Color _getBgColor(String color) {
    switch (color) {
      case 'teal':
        return const Color(0xFFE0F5F5);
      case 'blue':
        return const Color(0xFFE8F0FF);
      case 'pink':
        return const Color(0xFFFFE8F0);
      default:
        return const Color(0xFFFFF0E0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(teacher['color'] ?? 'orange');
    final bgColor = _getBgColor(teacher['color'] ?? 'orange');
    final initials = teacher['name']!
        .split(' ')
        .map((e) => e[0])
        .where((c) => c == c.toUpperCase())
        .take(2)
        .join();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: color,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.manrope(
                            color: color,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      teacher['name'] ?? '',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        teacher['subject'] ?? '',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildInfoCards(color, bgColor),
                const SizedBox(height: 20),
                _buildSubjectsSection(color, bgColor),
                const SizedBox(height: 20),
                _buildScheduleSection(color),
                const SizedBox(height: 20),
                _buildStatsSection(color),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(Color color, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoTile(
              icon: Icons.class_rounded,
              label: 'Class',
              value: teacher['class'] ?? 'N/A',
              color: color,
              bgColor: bgColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoTile(
              icon: Icons.timer_rounded,
              label: 'Experience',
              value: teacher['exp'] ?? 'N/A',
              color: color,
              bgColor: bgColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoTile(
              icon: Icons.people_rounded,
              label: 'Students',
              value: '42',
              color: color,
              bgColor: bgColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
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
            offset: const Offset(0, 4),
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
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsSection(Color color, Color bgColor) {
    final subjects = [
      teacher['subject'] ?? 'N/A',
      'Extra Curriculum',
      'Homeroom',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SUBJECTS & ROLES',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black45,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subjects
                  .map(
                    (s) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    s,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection(Color color) {
    final schedule = [
      {'day': 'Monday',    'time': '9:00 - 11:00 AM',  'class': 'Grade 10A'},
      {'day': 'Tuesday',   'time': '10:00 - 12:00 PM', 'class': 'Grade 9B'},
      {'day': 'Wednesday', 'time': '8:00 - 10:00 AM',  'class': 'Grade 10B'},
      {'day': 'Thursday',  'time': '11:00 - 1:00 PM',  'class': 'Grade 8A'},
      {'day': 'Friday',    'time': '9:00 - 11:00 AM',  'class': 'Grade 10A'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WEEKLY SCHEDULE',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black45,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 14),
            ...schedule.map(
                  (s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        s['day']!,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        s['time']!,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s['class']!,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERFORMANCE',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black45,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Attendance Rate', 0.96, '96%', color),
            const SizedBox(height: 14),
            _buildStatRow('Homework Reviewed', 0.88, '88%', color),
            const SizedBox(height: 14),
            _buildStatRow('Student Satisfaction', 0.92, '92%', color),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
      String label,
      double value,
      String percent,
      Color color,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            Text(
              percent,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 7,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}