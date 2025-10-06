import 'package:flutter/material.dart';

// Resume Screens
import 'screens/splash_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/education_screen.dart';
import 'screens/skills_screen.dart';
import 'screens/projects_experience_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/resume_form_screen.dart';

// CV Screens
import 'screens/cv_form_screen.dart';
// ❌ Don't import CVPersonalInfoScreen here for direct route instantiation with required parameters
import 'screens/cv_education_screen.dart';
import 'screens/cv_skills_screen.dart';
import 'screens/cv_projects_experience_screen.dart';
import 'screens/cv_additional_section_screen.dart';
import 'screens/cv_template_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resume & CV Builder',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,

      initialRoute: '/',
      routes: {
        // Resume Routes
        '/': (context) => SplashScreen(),
        '/personal_info': (context) => PersonalInfoScreen(),
        '/education': (context) => EducationScreen(),
        '/skills': (context) => SkillsScreen(),
        '/projects': (context) => ProjectsExperienceScreen(),
        // '/preview': (context) => PreviewScreen(),
        '/resume_form': (context) => const ResumeFormScreen(),

        // CV Routes (No direct instantiation of screens with required params)
        '/cv_form': (context) => const CVFormScreen(),
        '/cv_education': (context) => CVEducationScreen(),
        '/cv_skills': (context) => CvSkillsScreen(),
        '/cv_projects_experience': (context) => CVProjectsExperienceScreen(),
        '/cv_additional': (context) => CvAdditionalSectionScreen(),
        '/cv_template_selection': (context) => CvTemplateSelectionScreen(),
        // ⚠️ '/cv_personal_info' route removed, use only in CVFormScreen flow
      },
    );
  }
}
