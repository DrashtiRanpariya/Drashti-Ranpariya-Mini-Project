import 'package:flutter/material.dart';
import '../models/resume_data.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  SkillsScreenState createState() => SkillsScreenState();
}

class SkillsScreenState extends State<SkillsScreen> {
  final TextEditingController techSkillController = TextEditingController();
  final TextEditingController softSkillController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController toolsController = TextEditingController();

  List<String> techSkills = [];
  List<String> softSkills = [];
  List<String> languages = [];
  List<String> tools = [];

  final resumeData = ResumeData();

  void _addSkill(String category) {
    setState(() {
      String value;
      switch (category) {
        case 'tech':
          value = techSkillController.text.trim();
          if (value.isNotEmpty && !techSkills.contains(value)) {
            techSkills.add(value);
            techSkillController.clear();
          }
          break;
        case 'soft':
          value = softSkillController.text.trim();
          if (value.isNotEmpty && !softSkills.contains(value)) {
            softSkills.add(value);
            softSkillController.clear();
          }
          break;
        case 'lang':
          value = languageController.text.trim();
          if (value.isNotEmpty && !languages.contains(value)) {
            languages.add(value);
            languageController.clear();
          }
          break;
        case 'tools':
          value = toolsController.text.trim();
          if (value.isNotEmpty && !tools.contains(value)) {
            tools.add(value);
            toolsController.clear();
          }
          break;
      }
    });
  }

  void _removeSkill(String skill, String category) {
    setState(() {
      switch (category) {
        case 'tech':
          techSkills.remove(skill);
          break;
        case 'soft':
          softSkills.remove(skill);
          break;
        case 'lang':
          languages.remove(skill);
          break;
        case 'tools':
          tools.remove(skill);
          break;
      }
    });
  }

  /// ✅ Method to validate and save data (used by GlobalKey)
  bool saveData() {
    if (techSkills.isEmpty &&
        softSkills.isEmpty &&
        languages.isEmpty &&
        tools.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one skill")),
      );
      return false;
    }

    resumeData.technicalSkills = techSkills;
    resumeData.softSkills = softSkills;
    resumeData.languages = languages;
    resumeData.toolsTechnologies = tools;

    return true;
  }

  Widget buildSkillField(String label, TextEditingController controller, List<String> skills, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter $label',
                  filled: true,
                  fillColor: Colors.deepPurple.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _addSkill(category),
              icon: const Icon(Icons.add),
              label: const Text("Add"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: Colors.deepPurple.shade100,
              deleteIcon: const Icon(Icons.close, color: Colors.redAccent),
              onDeleted: () => _removeSkill(skill, category),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  void dispose() {
    techSkillController.dispose();
    softSkillController.dispose();
    languageController.dispose();
    toolsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Skills", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildSkillField("Technical Skills", techSkillController, techSkills, 'tech'),
            buildSkillField("Soft Skills", softSkillController, softSkills, 'soft'),
            buildSkillField("Languages", languageController, languages, 'lang'),
            buildSkillField("Tools & Technologies", toolsController, tools, 'tools'),
          ],
        ),
      ),
    );
  }
}
