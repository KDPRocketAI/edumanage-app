import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class AddTeacherScreen extends StatefulWidget {
  final String schoolId;

  const AddTeacherScreen({
    super.key,
    required this.schoolId,
  });

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedClass;
  bool _isAdding = false;
  final _firestoreService = FirestoreService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addTeacher() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isAdding = true);
    debugPrint("Add Teacher clicked");

    try {
      // NOTE: In a real app, you might want to use a Cloud Function to create users 
      // without signing out the admin. For this fix, we will just add to Firestore.
      // If the app uses Firebase Auth for teachers, they'll need to be created there too.
      
      final teacherData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'subject': _subjectController.text.trim(),
        'class': _selectedClass,
        'role': 'teacher',
        'schoolId': widget.schoolId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('users').add(teacherData);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher added successfully'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding teacher: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
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
                        'Add Teacher',
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
                  _buildLabel('PASSWORD'),
                  _buildTextField(_passwordController, 'Enter password', isPassword: true),
                  const SizedBox(height: 16),
                  _buildLabel('PHONE NUMBER'),
                  _buildTextField(_phoneController, 'Enter phone number', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildLabel('SUBJECT'),
                  _buildTextField(_subjectController, 'Enter subject'),
                  const SizedBox(height: 16),
                  _buildLabel('ASSIGNED CLASS'),
                  _buildClassDropdown(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isAdding ? null : _addTeacher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B8FF7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isAdding
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Add Teacher',
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

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
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
