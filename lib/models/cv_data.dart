class Certification {
  final String title;
  final String issuer;
  final String year;

  Certification({
    required this.title,
    required this.issuer,
    required this.year,
  });
}

class Award {
  final String title;
  final String description;
  final String year;

  Award({
    required this.title,
    required this.description,
    required this.year,
  });
}

class CVData {
  // Singleton pattern — shared instance
  static final CVData _instance = CVData._internal();

  factory CVData() {
    return _instance;
  }

  CVData._internal();

  // 1. Personal Info
  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  String linkedin = '';
  String github = '';
  String website = '';

  // 2. Education
  List<Map<String, String>> education = [];

  // 3. Skills
  List<String> technicalSkills = [];
  List<String> softSkills = [];
  List<String> languages = [];
  List<String> toolsTechnologies = [];

  // 4. Projects
  List<Map<String, String>> projects = [];

  // 5. Experience
  List<Map<String, String>> experience = [];

  // 6. Additional Sections
  String professionalSummary = '';
  List<String> responsibilities = [];
  List<Certification> certifications = [];
  List<Award> awards = [];
  List<String> hobbies = [];

  // 7. New Sections for CV
  List<String> publications = [];
  List<String> conferences = [];
  List<String> references = [];
  List<String> researchExperiences = [];
  List<String> professionalDevelopments = [];
  List<String> teachingExperiences = [];
  List<String> grants = [];

  // Method to clear all data
  void clearAll() {
    // Personal Info
    name = '';
    email = '';
    phone = '';
    address = '';
    linkedin = '';
    github = '';
    website = '';

    // Education
    education.clear();

    // Skills
    technicalSkills.clear();
    softSkills.clear();
    languages.clear();
    toolsTechnologies.clear();

    // Projects & Experience
    projects.clear();
    experience.clear();

    // Additional Sections
    professionalSummary = '';
    responsibilities.clear();
    certifications.clear();
    awards.clear();
    hobbies.clear();

    // New CV Sections
    publications.clear();
    conferences.clear();
    references.clear();
    researchExperiences.clear();
    professionalDevelopments.clear();
    teachingExperiences.clear();
    grants.clear();
  }
}
