import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class EditStudentScreen extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> studentData;
  final String schoolId;

  const EditStudentScreen({
    super.key,
    required this.studentId,
    required this.studentData,
    required this.schoolId,
  });

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _rollController;
  late TextEditingController _parentNameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  String? _selectedClass;
  bool _isUpdating = false;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.studentData['name']);
    _rollController = TextEditingController(text: widget.studentData['rollNo']);
    _parentNameController = TextEditingController(text: widget.studentData['parentName']);
    _phoneController = TextEditingController(text: widget.studentData['parentPhone']);
    _passwordController = TextEditingController();
    _selectedClass = widget.studentData['class'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      final Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'class': _selectedClass,
        'rollNo': _rollController.text.trim(),
        'parentName': _parentNameController.text.trim(),
        'parentPhone': _phoneController.text.trim(),
      };

      if (_passwordController.text.isNotEmpty) {
        // In a real app, you'd hash this or use a specific service
        updateData['parentPassword'] = _passwordController.text;
      }

      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .update(updateData);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating student: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // Dialog-like background
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
                        'Edit Student',
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
                  _buildLabel('STUDENT NAME'),
                  _buildTextField(_nameController, 'Enter student name'),
                  const SizedBox(height: 16),
                  _buildLabel('CLASS'),
                  _buildClassDropdown(),
                  const SizedBox(height: 16),
                  _buildLabel('ROLL NUMBER (STUDENT ID)'),
                  _buildTextField(_rollController, 'Enter roll number'),
                  const SizedBox(height: 16),
                  _buildLabel('PARENT NAME'),
                  _buildTextField(_parentNameController, 'Enter parent name'),
                  const SizedBox(height: 16),
                  _buildLabel('PARENT PHONE'),
                  _buildTextField(_phoneController, 'Enter phone number', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildLabel('PARENT LOGIN PASSWORD'),
                  _buildTextField(_passwordController, 'Leave blank to keep current', isPassword: true),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _updateStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B8FF7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isUpdating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Update Student',
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
        if (!isPassword && (value == null || value.isEmpty)) {
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
