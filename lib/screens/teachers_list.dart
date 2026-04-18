import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/custom_bottom_nav.dart';
import 'admin_dashboard.dart';
import 'students_grid.dart';
import 'attendance_screen.dart';
import 'edit_teacher_screen.dart';
import 'add_teacher_screen.dart';

class TeachersList extends StatefulWidget {
  const TeachersList({super.key});

  @override
  State<TeachersList> createState() => _TeachersListState();
}

class _TeachersListState extends State<TeachersList> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // Extract number from teacher name (e.g., "Teacher 7" -> 7)
  int _extractTeacherNumber(String name) {
    final numberMatch = RegExp(r'\d+').firstMatch(name);
    if (numberMatch != null) {
      return int.tryParse(numberMatch.group(0)!) ?? 9999;
    }
    return 9999; // Put names without numbers at the end
  }

  Future<void> _deleteTeacher(String teacherId, String name) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(teacherId).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name deleted successfully'), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showTeacherProfile(String teacherId, Map<String, dynamic> data, String schoolId) {
    debugPrint('Opening teacher profile modal for: $teacherId');
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Teacher Profile',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.black26),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildProfileField('NAME', data['name'] ?? 'Unknown'),
                  const SizedBox(height: 16),
                  _buildProfileField('EMAIL', data['email'] ?? 'N/A'),
                  const SizedBox(height: 16),
                  _buildProfileField('SUBJECT', data['subject'] ?? 'N/A'),
                  const SizedBox(height: 16),
                  _buildProfileField('CLASS', data['class'] ?? 'N/A'),
                  const SizedBox(height: 16),
                  _buildProfileField('SCHOOL ID', schoolId),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalButton(
                          label: 'Edit',
                          icon: Icons.edit_outlined,
                          color: const Color(0xFFFFB74D),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTeacherScreen(
                                  teacherId: teacherId,
                                  teacherData: data,
                                  schoolId: schoolId,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModalButton(
                          label: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          color: const Color(0xFFFF5252),
                          onTap: () {
                            Navigator.pop(context);
                            _deleteTeacher(teacherId, data['name'] ?? 'Teacher');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.black38,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildModalButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
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
          return const Scaffold(body: Center(child: Text('Unauthorized or School ID not found')));
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF0F0F7),
          appBar: _buildAppBar(),
          drawer: const SidebarDrawer(currentRoute: 'teachers'),
          body: Column(
            children: [
              _buildHeaderRow(schoolId),
              _buildSearchBar(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('schoolId', isEqualTo: schoolId)
                      .where('role', isEqualTo: 'teacher')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    var docs = snapshot.data?.docs ?? [];
                    
                    // Apply sorting logic
                    docs.sort((a, b) {
                      final dataA = a.data() as Map<String, dynamic>;
                      final dataB = b.data() as Map<String, dynamic>;
                      final nameA = (dataA['name'] ?? '').toString().toLowerCase();
                      final nameB = (dataB['name'] ?? '').toString().toLowerCase();

                      final numA = _extractTeacherNumber(nameA);
                      final numB = _extractTeacherNumber(nameB);

                      if (numA != numB) {
                        return numA.compareTo(numB);
                      }
                      return nameA.compareTo(nameB);
                    });

                    // Debug print sorted names
                    debugPrint('Sorted Teachers: ${docs.map((d) => (d.data() as Map)['name']).toList()}');

                    final filtered = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '').toString().toLowerCase();
                      final subject = (data['subject'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery.toLowerCase()) || subject.contains(_searchQuery.toLowerCase());
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            '${filtered.length} Teachers',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          child: filtered.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final doc = filtered[index];
                                    final data = doc.data() as Map<String, dynamic>;
                                    return _buildTeacherCard(doc.id, data, schoolId);
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: const CustomBottomNav(selectedIndex: 2),
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
        'Teachers',
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              debugPrint("Add Teacher clicked");
              _navigateTo(AddTeacherScreen(schoolId: schoolId));
            },
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: Text(
              'Add Teacher',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B8FF7),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search teachers...',
            hintStyle: GoogleFonts.manrope(color: Colors.black26, fontSize: 14),
            prefixIcon: const Icon(Icons.search, size: 20, color: Colors.black38),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherCard(String teacherId, Map<String, dynamic> data, String schoolId) {
    return InkWell(
      onTap: () => _showTeacherProfile(teacherId, data, schoolId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? 'Unknown',
                      style: GoogleFonts.manrope(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data['subject'] ?? '-'} · ${data['class'] ?? '-'}',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildActionIcon(Icons.edit_outlined, const Color(0xFFFFB74D), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditTeacherScreen(
                          teacherId: teacherId,
                          teacherData: data,
                          schoolId: schoolId,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  _buildActionIcon(Icons.delete_outline_rounded, const Color(0xFFFF5252), () => _deleteTeacher(teacherId, data['name'] ?? 'Teacher')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_rounded, size: 64, color: Colors.black12),
          const SizedBox(height: 16),
          Text(
            'No teachers found',
            style: GoogleFonts.manrope(color: Colors.black38, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
