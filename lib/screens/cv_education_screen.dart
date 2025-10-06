import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cv_data.dart';

class CVEducationScreen extends StatefulWidget {
  @override
  State<CVEducationScreen> createState() => _CVEducationScreenState();
}

class _CVEducationScreenState extends State<CVEducationScreen>
    with SingleTickerProviderStateMixin {
  List<EducationEntry> educationList = [];
  final _formKey = GlobalKey<FormState>();
  final collegeController = TextEditingController();
  final degreeController = TextEditingController();
  final yearController = TextEditingController();
  final cgpaController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  void addEntry() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        final newEntry = EducationEntry(
          college: collegeController.text,
          degree: degreeController.text,
          year: yearController.text,
          cgpa: cgpaController.text,
        );

        educationList.add(newEntry);

        final cvData = CVData();
        cvData.education.add({
          'degree': degreeController.text,
          'school': collegeController.text,
          'year': yearController.text,
          'cgpa': cgpaController.text,
        });

        collegeController.clear();
        degreeController.clear();
        yearController.clear();
        cgpaController.clear();
      });
    }
  }

  void removeEntry(int index) {
    setState(() {
      educationList.removeAt(index);
      final cvData = CVData();
      if (index < cvData.education.length) {
        cvData.education.removeAt(index);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    collegeController.dispose();
    degreeController.dispose();
    yearController.dispose();
    cgpaController.dispose();
    super.dispose();
  }

  Widget buildField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        style: GoogleFonts.poppins(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) =>
        value == null || value.isEmpty ? 'Required field' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text(
            "CV - Education",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildField(collegeController, "College/University Name"),
                      buildField(degreeController, "Degree (e.g., B.Tech)"),
                      buildField(yearController, "Passing Year",
                          keyboardType: TextInputType.number),
                      buildField(cgpaController, "CGPA/Percentage",
                          keyboardType: TextInputType.number),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: addEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Text(
                            "Add Education",
                            key: ValueKey("Add Education"),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (educationList.isNotEmpty)
                  ListView.builder(
                    itemCount: educationList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final entry = educationList[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          title: Text(
                            "${entry.degree} - ${entry.college}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Year: ${entry.year} | CGPA: ${entry.cgpa}",
                            style: GoogleFonts.poppins(),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => removeEntry(index),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EducationEntry {
  String college;
  String degree;
  String year;
  String cgpa;

  EducationEntry({
    required this.college,
    required this.degree,
    required this.year,
    required this.cgpa,
  });
}
