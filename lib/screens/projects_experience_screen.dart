import 'package:flutter/material.dart';
import '../models/resume_data.dart';

class ProjectsExperienceScreen extends StatefulWidget {
  const ProjectsExperienceScreen({Key? key}) : super(key: key);

  @override
  ProjectsExperienceScreenState createState() => ProjectsExperienceScreenState();
}

class ProjectsExperienceScreenState extends State<ProjectsExperienceScreen> {
  final ResumeData resumeData = ResumeData();

  // Controllers for projects
  final TextEditingController projectTitleController = TextEditingController();
  final TextEditingController projectDescController = TextEditingController();

  // Controllers for experience
  final TextEditingController roleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  bool saveData() {
    return resumeData.projects.isNotEmpty || resumeData.experience.isNotEmpty;
  }

  void addProject() {
    if (projectTitleController.text.isNotEmpty &&
        projectDescController.text.isNotEmpty) {
      setState(() {
        resumeData.projects.add(Project(
          title: projectTitleController.text.trim(),
          description: projectDescController.text.trim(),
        ));
        projectTitleController.clear();
        projectDescController.clear();
      });
    }
  }

  void addExperience() {
    if (roleController.text.isNotEmpty &&
        companyController.text.isNotEmpty &&
        durationController.text.isNotEmpty) {
      setState(() {
        resumeData.experience.add(Experience(
          role: roleController.text.trim(),
          company: companyController.text.trim(),
          year: durationController.text.trim(),
        ));
        roleController.clear();
        companyController.clear();
        durationController.clear();
      });
    }
  }

  void removeProject(int index) {
    setState(() {
      resumeData.projects.removeAt(index);
    });
  }

  void removeExperience(int index) {
    setState(() {
      resumeData.experience.removeAt(index);
    });
  }

  @override
  void dispose() {
    projectTitleController.dispose();
    projectDescController.dispose();
    roleController.dispose();
    companyController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.deepPurple.shade600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        centerTitle: true,
        title: const Text("Projects & Experience", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("Projects"),
            buildProjectForm(),
            ...resumeData.projects.asMap().entries.map((entry) {
              final p = entry.value;
              return buildCard(
                child: ListTile(
                  title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(p.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeProject(entry.key),
                  ),
                ),
              );
            }),

            const SizedBox(height: 30),

            sectionTitle("Experience"),
            buildExperienceForm(),
            ...resumeData.experience.asMap().entries.map((entry) {
              final e = entry.value;
              return buildCard(
                child: ListTile(
                  title: Text("${e.role} at ${e.company}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(e.year),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeExperience(entry.key),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700),
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
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: addProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text("Add Project"),
          ),
        ),
      ],
    );
  }

  Widget buildExperienceForm() {
    return Column(
      children: [
        buildTextField(roleController, "Role (e.g., Intern, Developer)"),
        buildTextField(companyController, "Company Name"),
        buildTextField(durationController, "Duration (e.g., Jan–Apr 2024)"),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: addExperience,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text("Add Experience"),
          ),
        ),
      ],
    );
  }

  Widget buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }
}
