import 'package:flutter/material.dart';
import '../models/cv_data.dart';

class CVProjectsExperienceScreen extends StatefulWidget {
  @override
  State<CVProjectsExperienceScreen> createState() => _CVProjectsExperienceScreenState();
}

class _CVProjectsExperienceScreenState extends State<CVProjectsExperienceScreen> {
  final cvData = CVData();

  final projectTitleController = TextEditingController();
  final projectDescController = TextEditingController();
  final techStackController = TextEditingController();

  final roleController = TextEditingController();
  final companyController = TextEditingController();
  final durationController = TextEditingController();
  final jobDescController = TextEditingController();

  void addProject() {
    if (projectTitleController.text.isNotEmpty &&
        projectDescController.text.isNotEmpty &&
        techStackController.text.isNotEmpty) {
      setState(() {
        cvData.projects.add({
          'title': projectTitleController.text,
          'desc': projectDescController.text,
          'tech': techStackController.text,
        });
        projectTitleController.clear();
        projectDescController.clear();
        techStackController.clear();
      });
    }
  }

  void addExperience() {
    if (roleController.text.isNotEmpty &&
        companyController.text.isNotEmpty &&
        durationController.text.isNotEmpty &&
        jobDescController.text.isNotEmpty) {
      setState(() {
        cvData.experience.add({
          'role': roleController.text,
          'company': companyController.text,
          'duration': durationController.text,
          'desc': jobDescController.text,
        });
        roleController.clear();
        companyController.clear();
        durationController.clear();
        jobDescController.clear();
      });
    }
  }

  void removeProject(int index) {
    setState(() => cvData.projects.removeAt(index));
  }

  void removeExperience(int index) {
    setState(() => cvData.experience.removeAt(index));
  }

  @override
  void dispose() {
    projectTitleController.dispose();
    projectDescController.dispose();
    techStackController.dispose();
    roleController.dispose();
    companyController.dispose();
    durationController.dispose();
    jobDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.deepPurple.shade600;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        centerTitle: true,
        title: Text(
          "Projects & Experience",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle("Projects"),
              buildProjectForm(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: cvData.projects.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (_, index) {
                  final p = cvData.projects[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(p['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text("Tech: ${p['tech']}\n${p['desc']}"),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeProject(index),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 30),
              sectionTitle("Experience"),
              buildExperienceForm(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: cvData.experience.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (_, index) {
                  final e = cvData.experience[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text("${e['role']} at ${e['company']}", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text("${e['duration']}\n${e['desc']}"),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeExperience(index),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // SizedBox(height: 20),
              // Center(
              //   child: Text(
              //     "Developed by Drashti Ranpariya",
              //     style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.deepPurple.shade700),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildProjectForm() {
    return Column(
      children: [
        buildTextField(projectTitleController, "Project Title"),
        buildTextField(projectDescController, "Description", maxLines: 2),
        buildTextField(techStackController, "Tech Stack (e.g., Flutter, Firebase)"),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: addProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: Text("Add Project", style: TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildExperienceForm() {
    return Column(
      children: [
        buildTextField(roleController, "Role (e.g., Intern, Developer)"),
        buildTextField(companyController, "Company Name"),
        buildTextField(durationController, "Duration (e.g., Jan–Apr 2024)"),
        buildTextField(jobDescController, "Job Description", maxLines: 2),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: addExperience,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: Text("Add Experience", style: TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
