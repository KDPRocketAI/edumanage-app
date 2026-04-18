import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _deleteNotice(String id, String title) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notice'),
        content: Text('Are you sure you want to delete "$title"?'),
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
        await FirebaseFirestore.instance.collection('notices').doc(id).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notice deleted successfully'), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
        if (schoolId == null) return const Scaffold(body: Center(child: Text('Unauthorized')));

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
              'Notices',
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
          drawer: const SidebarDrawer(currentRoute: 'notices'),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notices')
                .where('schoolId', isEqualTo: schoolId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data?.docs ?? [];
              
              // Sort client-side to avoid index requirement
              docs.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final dateA = dataA['date'];
                final dateB = dataB['date'];
                if (dateA == null || dateB == null) return 0;
                DateTime dtA = dateA is Timestamp ? dateA.toDate() : DateTime.tryParse(dateA.toString()) ?? DateTime(2000);
                DateTime dtB = dateB is Timestamp ? dateB.toDate() : DateTime.tryParse(dateB.toString()) ?? DateTime(2000);
                return dtB.compareTo(dtA);
              });

              debugPrint("Fetched ${docs.length} notices for school $schoolId");

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.campaign_outlined, size: 64, color: Colors.black12),
                      const SizedBox(height: 16),
                      Text(
                        'No notices available',
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

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final id = docs[index].id;
                  return _buildNoticeCard(id, data);
                },
              );
            },
          ),
          bottomNavigationBar: const CustomBottomNav(selectedIndex: 5),
        );
      },
    );
  }

  Widget _buildNoticeCard(String id, Map<String, dynamic> data) {
    final title = data['title'] ?? 'No Title';
    final message = data['message'] ?? 'No message content';
    final target = data['target'] ?? 'All';
    final type = data['type'] ?? 'NORMAL';
    
    String dateStr = 'Unknown date';
    if (data['date'] != null) {
      if (data['date'] is Timestamp) {
        dateStr = DateFormat('dd MMM yyyy, hh:mm a').format((data['date'] as Timestamp).toDate());
      } else if (data['date'] is String) {
        dateStr = data['date'];
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: type == 'URGENT' ? Colors.red.withOpacity(0.1) : const Color(0xFF7B8FF7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: type == 'URGENT' ? Colors.red : const Color(0xFF7B8FF7),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.orange),
                      onPressed: () {
                        // Logic to open EditNoticeScreen would go here
                        debugPrint("Edit clicked for notice: $id");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      onPressed: () => _deleteNotice(id, title),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: Colors.black38),
                    const SizedBox(width: 6),
                    Text(
                      'Target: $target',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateStr,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
