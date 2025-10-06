import 'package:flutter/material.dart';
import 'personal_info_screen.dart';
import 'education_screen.dart';
import 'skills_screen.dart';
import 'projects_experience_screen.dart';
import 'additional_section_screen.dart';
import 'template_selection_screen.dart';
import '../models/resume_data.dart';

class ResumeFormScreen extends StatefulWidget {
  const ResumeFormScreen({super.key});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> {
  final PageController _pageController = PageController();
  final ScrollController _tabScrollController = ScrollController();
  int _currentPage = 0;

  final ResumeData resumeData = ResumeData();

  final List<String> _sectionTitles = [
    "Personal Info",
    "Education",
    "Skills",
    "Projects/Experience",
    "Additional",
    "Select Template",
  ];

  // Global keys for each form
  final GlobalKey<PersonalInfoScreenState> _personalKey = GlobalKey();
  final GlobalKey<EducationScreenState> _educationKey = GlobalKey();
  final GlobalKey<SkillsScreenState> _skillsKey = GlobalKey();
  final GlobalKey<ProjectsExperienceScreenState> _projectsKey = GlobalKey();
  final GlobalKey<AdditionalSectionScreenState> _additionalKey = GlobalKey();

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    setState(() => _currentPage = index);

    _tabScrollController.animateTo(
      index * 130,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
  }

  void _nextPage() {
    bool isValid = true;

    switch (_currentPage) {
      case 0:
        isValid = _personalKey.currentState?.saveData() ?? false;
        break;
      case 1:
        isValid = _educationKey.currentState?.saveData() ?? false;
        break;
      case 2:
        isValid = _skillsKey.currentState?.saveData() ?? false;
        break;
      case 3:
        isValid = _projectsKey.currentState?.saveData() ?? false;
        break;
      case 4:
        isValid = _additionalKey.currentState?.saveData() ?? false;
        break;
    }

    if (isValid && _currentPage < _sectionTitles.length - 1) {
      _goToPage(_currentPage + 1);
    }
  }

  Widget _buildTab(int index) {
    final isSelected = _currentPage == index;
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey[300],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          _sectionTitles[index],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Resume"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              controller: _tabScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _sectionTitles.length,
              itemBuilder: (context, index) => _buildTab(index),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                PersonalInfoScreen(key: _personalKey),
                EducationScreen(key: _educationKey),
                SkillsScreen(key: _skillsKey),
                ProjectsExperienceScreen(key: _projectsKey),
                AdditionalSectionScreen(key: _additionalKey),
                const TemplateSelectionScreen(),
              ],
            ),
          ),
          if (_currentPage < _sectionTitles.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _currentPage == 4 ? "Show Preview" : "Next",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
