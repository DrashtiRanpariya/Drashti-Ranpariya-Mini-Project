import 'package:flutter/material.dart';
import '../models/cv_data.dart';

class CvSkillsScreen extends StatefulWidget {
  @override
  State<CvSkillsScreen> createState() => _CvSkillsScreenState();
}

class _CvSkillsScreenState extends State<CvSkillsScreen> {
  final techSkillController = TextEditingController();
  final softSkillController = TextEditingController();
  final languageController = TextEditingController();
  final toolsController = TextEditingController();

  final cvData = CVData();

  List<String> techSkills = [];
  List<String> softSkills = [];
  List<String> languages = [];
  List<String> tools = [];

  void _addSkill(String category) {
    setState(() {
      String input;
      switch (category) {
        case 'tech':
          input = techSkillController.text.trim();
          if (input.isNotEmpty && !techSkills.contains(input)) {
            techSkills.add(input);
            techSkillController.clear();
          }
          break;
        case 'soft':
          input = softSkillController.text.trim();
          if (input.isNotEmpty && !softSkills.contains(input)) {
            softSkills.add(input);
            softSkillController.clear();
          }
          break;
        case 'lang':
          input = languageController.text.trim();
          if (input.isNotEmpty && !languages.contains(input)) {
            languages.add(input);
            languageController.clear();
          }
          break;
        case 'tools':
          input = toolsController.text.trim();
          if (input.isNotEmpty && !tools.contains(input)) {
            tools.add(input);
            toolsController.clear();
          }
          break;
      }

      // Auto-save on every change
      cvData.technicalSkills = techSkills;
      cvData.softSkills = softSkills;
      cvData.languages = languages;
      cvData.toolsTechnologies = tools;
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

      // Auto-save on removal
      cvData.technicalSkills = techSkills;
      cvData.softSkills = softSkills;
      cvData.languages = languages;
      cvData.toolsTechnologies = tools;
    });
  }

  Widget buildSkillInput(String label, TextEditingController controller, List<String> list, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Enter $label",
                  filled: true,
                  fillColor: Colors.teal.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _addSkill(category),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text("Add"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list
              .map((skill) => Chip(
            label: Text(skill),
            backgroundColor: Colors.teal.shade100,
            deleteIcon: Icon(Icons.close, color: Colors.red),
            onDeleted: () => _removeSkill(skill, category),
          ))
              .toList(),
        ),
        const SizedBox(height: 20),
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
      appBar: AppBar(
        title: const Text(
          "CV Skills",
          style: TextStyle(color: Colors.white), // Set text color to bright white
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // Optional: makes back button white
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            buildSkillInput("Technical Skills", techSkillController, techSkills, 'tech'),
            buildSkillInput("Soft Skills", softSkillController, softSkills, 'soft'),
            buildSkillInput("Languages", languageController, languages, 'lang'),
            buildSkillInput("Tools & Technologies", toolsController, tools, 'tools'),
          ],
        ),
      ),
    );
  }
}
