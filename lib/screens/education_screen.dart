import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/resume_data.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  EducationScreenState createState() => EducationScreenState();
}

class EducationScreenState extends State<EducationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final collegeController = TextEditingController();
  final degreeController = TextEditingController();
  final fieldController = TextEditingController();
  final startYearController = TextEditingController();
  final endYearController = TextEditingController();

  final resumeData = ResumeData();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    collegeController.dispose();
    degreeController.dispose();
    fieldController.dispose();
    startYearController.dispose();
    endYearController.dispose();
    super.dispose();
  }

  void addEntry() {
    // validate fields first
    if (_formKey.currentState?.validate() ?? false) {
      resumeData.education.add(
        Education(
          degree: degreeController.text.trim(),
          field: fieldController.text.trim(),
          school: collegeController.text.trim(),
          startYear: startYearController.text.trim(),
          endYear: endYearController.text.trim(),
        ),
      );
      clearFields();
      setState(() {});
    }
  }

  void clearFields() {
    collegeController.clear();
    degreeController.clear();
    fieldController.clear();
    startYearController.clear();
    endYearController.clear();
  }

  void removeEntry(int index) {
    resumeData.education.removeAt(index);
    setState(() {});
  }

  /// Called externally (for example by a parent wizard) to persist any filled entry
  bool saveData() {
    if (_formKey.currentState?.validate() ?? false) {
      addEntry();
      return true;
    }
    // If no filled fields, still return true (to match previous behavior)
    // but do not add an empty entry.
    if (collegeController.text.isEmpty &&
        degreeController.text.isEmpty &&
        fieldController.text.isEmpty &&
        startYearController.text.isEmpty &&
        endYearController.text.isEmpty) {
      return true;
    }
    return false;
  }

  Widget buildField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType? keyboardType,
        bool required = true,
      }) {
    final isYear = label.toLowerCase().contains('year');
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? (isYear ? TextInputType.number : TextInputType.text),
        style: GoogleFonts.poppins(fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          if (isYear && (value != null && value.trim().isNotEmpty)) {
            final v = value.trim();
            if (v.length != 4 || int.tryParse(v) == null) {
              return 'Enter valid year (YYYY)';
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F4F8),
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text(
            'Education',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Form area
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildField(collegeController, 'College / University', Icons.school),
                          buildField(degreeController, 'Degree (e.g., B.Tech)', Icons.menu_book),
                          buildField(fieldController, 'Field of Study', Icons.work),
                          Row(
                            children: [
                              Expanded(
                                child: buildField(startYearController, 'Start Year', Icons.calendar_today,
                                    keyboardType: TextInputType.number),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: buildField(endYearController, 'End Year', Icons.calendar_today,
                                    keyboardType: TextInputType.number),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: addEntry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: Text(
                              'Add Education',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Saved entries list
                Expanded(
                  flex: 5,
                  child: resumeData.education.isEmpty
                      ? Center(
                    child: Text(
                      'No education entries added yet.',
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                  )
                      : ListView.separated(
                    itemCount: resumeData.education.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = resumeData.education[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          title: Text(
                            '${entry.degree} in ${entry.field}',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${entry.school} (${entry.startYear} - ${entry.endYear})',
                            style: GoogleFonts.poppins(),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => removeEntry(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
