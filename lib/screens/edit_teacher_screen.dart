import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class EditTeacherScreen extends StatefulWidget {
  final String teacherId;
  final Map<String, dynamic> teacherData;
  final String schoolId;

  const EditTeacherScreen({
    super.key,
    required this.teacherId,
    required this.teacherData,
    required this.schoolId,
  });

  @override
  State<EditTeacherScreen> createState() => _EditTeacherScreenState();
}

class _EditTeacherScreenState extends State<EditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _subjectController;
  String? _selectedClass;
  bool _isUpdating = false;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacherData['name']);
    _emailController = TextEditingController(text: widget.teacherData['email']);
    _phoneController = TextEditingController(text: widget.teacherData['phone'] ?? '');
    _subjectController = TextEditingController(text: widget.teacherData['subject']);
    _selectedClass = widget.teacherData['class'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _updateTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      final updateData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'subject': _subjectController.text.trim(),
        'class': _selectedClass,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.teacherId)
          .update(updateData);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher updated successfully'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating teacher: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Teacher',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5C6BC0),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildLabel('TEACHER NAME'),
                  _buildTextField(_nameController, 'Enter teacher name'),
                  const SizedBox(height: 16),
                  _buildLabel('EMAIL ADDRESS'),
                  _buildTextField(_emailController, 'Enter email', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildLabel('PHONE NUMBER'),
                  _buildTextField(_phoneController, 'Enter phone number', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildLabel('SUBJECT'),
                  _buildTextField(_subjectController, 'Enter subject'),
                  const SizedBox(height: 16),
                  _buildLabel('CLASS'),
                  _buildClassDropdown(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _updateTeacher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B8FF7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isUpdating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Update Teacher',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.manrope(color: Colors.black26, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildClassDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getClasses(widget.schoolId),
      builder: (context, snapshot) {
        List<String> classes = [];
        if (snapshot.hasData) {
          classes = snapshot.data!.docs
              .map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString())
              .toList();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: classes.contains(_selectedClass) ? _selectedClass : null,
              hint: Text('Select class', style: GoogleFonts.manrope(color: Colors.black26, fontSize: 14)),
              items: classes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.manrope(fontSize: 14)),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() => _selectedClass = newValue);
              },
            ),
          ),
        );
      },
    );
  }
}
