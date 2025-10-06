import 'package:flutter/material.dart';
import '../models/cv_data.dart';

class CvAdditionalSectionScreen extends StatefulWidget {
  @override
  State<CvAdditionalSectionScreen> createState() => _CvAdditionalSectionScreenState();
}

class _CvAdditionalSectionScreenState extends State<CvAdditionalSectionScreen> {
  final cvData = CVData(); // Singleton access

  // Controllers for existing sections
  final summaryController = TextEditingController();
  final responsibilityController = TextEditingController();
  final certTitleController = TextEditingController();
  final certIssuerController = TextEditingController();
  final certYearController = TextEditingController();
  final awardTitleController = TextEditingController();
  final awardDescController = TextEditingController();
  final awardYearController = TextEditingController();
  final hobbyController = TextEditingController();

  // New sections controllers
  final publicationController = TextEditingController();
  final conferenceController = TextEditingController();
  final referenceController = TextEditingController();
  final researchController = TextEditingController();
  final profDevController = TextEditingController();
  final teachingController = TextEditingController();
  final grantsController = TextEditingController();

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

    publicationController.dispose();
    conferenceController.dispose();
    referenceController.dispose();
    researchController.dispose();
    profDevController.dispose();
    teachingController.dispose();
    grantsController.dispose();

    super.dispose();
  }

  // Generic add/delete functions
  void addItem(TextEditingController controller, List<String> list) {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        list.add(controller.text.trim());
        controller.clear();
      });
    }
  }

  void deleteItem(int index, List<String> list) {
    setState(() {
      list.removeAt(index);
    });
  }

  void addCertification() {
    if (certTitleController.text.isNotEmpty &&
        certIssuerController.text.isNotEmpty &&
        certYearController.text.isNotEmpty) {
      setState(() {
        cvData.certifications.add(Certification(
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
      cvData.certifications.removeAt(index);
    });
  }

  void addAward() {
    if (awardTitleController.text.isNotEmpty &&
        awardDescController.text.isNotEmpty &&
        awardYearController.text.isNotEmpty) {
      setState(() {
        cvData.awards.add(Award(
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
      cvData.awards.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.indigo.shade600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text("CV Additional Info", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField(summaryController, "Professional Summary", maxLines: 3),

            // Responsibilities
            sectionWithAdd("Responsibilities", themeColor, responsibilityController, cvData.responsibilities),

            // Certifications
            sectionTitle("Certifications", themeColor),
            buildTextField(certTitleController, "Title"),
            buildTextField(certIssuerController, "Issued By"),
            buildTextField(certYearController, "Year", keyboardType: TextInputType.number),
            addButton("Add Certification", addCertification),
            ...cvData.certifications.asMap().entries.map(
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

            // Awards
            sectionTitle("Awards & Honors", themeColor),
            buildTextField(awardTitleController, "Award Title"),
            buildTextField(awardDescController, "Description"),
            buildTextField(awardYearController, "Year", keyboardType: TextInputType.number),
            addButton("Add Award", addAward),
            ...cvData.awards.asMap().entries.map(
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

            // Hobbies
            sectionWithAdd("Interests / Hobbies", themeColor, hobbyController, cvData.hobbies),

            // Publications
            sectionWithAdd("Publications", themeColor, publicationController, cvData.publications),

            // Conferences / Workshops
            sectionWithAdd("Conferences / Workshops", themeColor, conferenceController, cvData.conferences),

            // References
            sectionWithAdd("References", themeColor, referenceController, cvData.references),

            // Research Experience
            sectionWithAdd("Research Experience", themeColor, researchController, cvData.researchExperiences),

            // Professional Development
            sectionWithAdd("Professional Development", themeColor, profDevController, cvData.professionalDevelopments),

            // Teaching Experience
            sectionWithAdd("Teaching Experience", themeColor, teachingController, cvData.teachingExperiences),

            // Grants / Funding
            sectionWithAdd("Grants / Funding", themeColor, grantsController, cvData.grants),
          ],
        ),
      ),
    );
  }

  // Helper widget for sections with add/delete
  Widget sectionWithAdd(String title, Color color, TextEditingController controller, List<String> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(title, color),
        buildTextField(controller, "Add $title"),
        addButton("Add $title", () => addItem(controller, list)),
        ...list.asMap().entries.map(
              (entry) => buildCard(
            child: ListTile(
              title: Text(entry.value),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteItem(entry.key, list),
              ),
            ),
          ),
        ),
      ],
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
          backgroundColor: Colors.indigo.shade600,
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
