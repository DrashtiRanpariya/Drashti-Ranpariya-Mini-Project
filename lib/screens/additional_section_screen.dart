import 'package:flutter/material.dart';
import '../models/resume_data.dart';
import 'template_selection_screen.dart';

class AdditionalSectionScreen extends StatefulWidget {
  const AdditionalSectionScreen({super.key});

  @override
  State<AdditionalSectionScreen> createState() => AdditionalSectionScreenState();
}

class AdditionalSectionScreenState extends State<AdditionalSectionScreen> {
  final resumeData = ResumeData();

  final summaryController = TextEditingController();
  final responsibilityController = TextEditingController();
  final certTitleController = TextEditingController();
  final certIssuerController = TextEditingController();
  final certYearController = TextEditingController();
  final awardTitleController = TextEditingController();
  final awardDescController = TextEditingController();
  final awardYearController = TextEditingController();
  final hobbyController = TextEditingController();

  bool saveData() {
    resumeData.professionalSummary = summaryController.text.trim();
    return true;
  }

  @override
  void initState() {
    super.initState();
    summaryController.text = resumeData.professionalSummary;
  }

  void addResponsibility() {
    if (responsibilityController.text.trim().isNotEmpty) {
      setState(() {
        resumeData.responsibilities.add(responsibilityController.text.trim());
        responsibilityController.clear();
      });
    }
  }

  void deleteResponsibility(int index) {
    setState(() {
      resumeData.responsibilities.removeAt(index);
    });
  }

  void addCertification() {
    if (certTitleController.text.isNotEmpty &&
        certIssuerController.text.isNotEmpty &&
        certYearController.text.isNotEmpty) {
      setState(() {
        resumeData.certifications.add(Certification(
          title: certTitleController.text,
          issuer: certIssuerController.text,
          year: certYearController.text,
        ));
        certTitleController.clear();
        certIssuerController.clear();
        certYearController.clear();
      });
    }
  }

  void deleteCertification(int index) {
    setState(() {
      resumeData.certifications.removeAt(index);
    });
  }

  void addAward() {
    if (awardTitleController.text.isNotEmpty &&
        awardDescController.text.isNotEmpty &&
        awardYearController.text.isNotEmpty) {
      setState(() {
        resumeData.awards.add(Award(
          title: awardTitleController.text,
          description: awardDescController.text,
          year: awardYearController.text,
        ));
        awardTitleController.clear();
        awardDescController.clear();
        awardYearController.clear();
      });
    }
  }

  void deleteAward(int index) {
    setState(() {
      resumeData.awards.removeAt(index);
    });
  }

  void addHobby() {
    if (hobbyController.text.trim().isNotEmpty) {
      setState(() {
        resumeData.hobbies.add(hobbyController.text.trim());
        hobbyController.clear();
      });
    }
  }

  void deleteHobby(int index) {
    setState(() {
      resumeData.hobbies.removeAt(index);
    });
  }

  @override
  void dispose() {
    summaryController.dispose();
    responsibilityController.dispose();
    certTitleController.dispose();
    certIssuerController.dispose();
    certYearController.dispose();
    awardTitleController.dispose();
    awardDescController.dispose();
    awardYearController.dispose();
    hobbyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal.shade600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text("Additional Information", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField(summaryController, "Professional Summary", maxLines: 3),

            sectionTitle("Responsibilities", themeColor),
            buildTextField(responsibilityController, "Add Responsibility"),
            addButton("Add Responsibility", addResponsibility),
            ...resumeData.responsibilities.asMap().entries.map(
                  (entry) => buildCard(
                child: ListTile(
                  title: Text(entry.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteResponsibility(entry.key),
                  ),
                ),
              ),
            ),

            sectionTitle("Certifications", themeColor),
            buildTextField(certTitleController, "Title"),
            buildTextField(certIssuerController, "Issued By"),
            buildTextField(certYearController, "Year", keyboardType: TextInputType.number),
            addButton("Add Certification", addCertification),
            ...resumeData.certifications.asMap().entries.map(
                  (entry) => buildCard(
                child: ListTile(
                  title: Text("${entry.value.title} (${entry.value.year})"),
                  subtitle: Text("Issued by: ${entry.value.issuer}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteCertification(entry.key),
                  ),
                ),
              ),
            ),

            sectionTitle("Awards & Honors", themeColor),
            buildTextField(awardTitleController, "Award Title"),
            buildTextField(awardDescController, "Description"),
            buildTextField(awardYearController, "Year", keyboardType: TextInputType.number),
            addButton("Add Award", addAward),
            ...resumeData.awards.asMap().entries.map(
                  (entry) => buildCard(
                child: ListTile(
                  title: Text("${entry.value.title} (${entry.value.year})"),
                  subtitle: Text(entry.value.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteAward(entry.key),
                  ),
                ),
              ),
            ),

            sectionTitle("Interests / Hobbies", themeColor),
            buildTextField(hobbyController, "Add Hobby"),
            addButton("Add Hobby", addHobby),
            ...resumeData.hobbies.asMap().entries.map(
                  (entry) => buildCard(
                child: ListTile(
                  title: Text(entry.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteHobby(entry.key),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget addButton(String label, VoidCallback onPressed) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
        ),
        child: Text(label),
      ),
    );
  }

  Widget buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }
}
