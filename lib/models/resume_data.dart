class ResumeData {
  // Singleton pattern
  static final ResumeData _instance = ResumeData._internal();
  factory ResumeData() => _instance;
  ResumeData._internal();

  // Personal Info
  String name = '';
  String role = '';
  String email = '';
  String phone = '';
  String address = '';
  String linkedin = '';
  String github = '';
  String website = '';

  // Education
  List<Education> education = [];

  // Skills
  List<String> technicalSkills = [];
  List<String> softSkills = [];
  List<String> languages = [];
  List<String> toolsTechnologies = [];

  // Projects
  List<Project> projects = [];

  // Experience
  List<Experience> experience = [];

  // Additional Sections
  String professionalSummary = '';
  List<String> responsibilities = [];
  List<Certification> certifications = [];
  List<Award> awards = [];
  List<String> hobbies = [];

  // Clear all data (reset method)
  void clearAll() {
    name = '';
    email = '';
    phone = '';
    address = '';
    linkedin = '';
    github = '';
    website = '';

    education.clear();
    technicalSkills.clear();
    softSkills.clear();
    languages.clear();
    toolsTechnologies.clear();

    projects.clear();
    experience.clear();
    professionalSummary = '';
    responsibilities.clear();
    certifications.clear();
    awards.clear();
    hobbies.clear();
  }
}

// Education model
class Education {
  String degree;
  String field;
  String school;
  String startYear;
  String endYear;

  Education({
    required this.degree,
    required this.field,
    required this.school,
    required this.startYear,
    required this.endYear,
  });
}

// Project model
class Project {
  String title;
  String description;

  Project({
    required this.title,
    required this.description,
  });
}

// Experience model
class Experience {
  String role;
  String company;
  String year;

  Experience({
    required this.role,
    required this.company,
    required this.year,
  });
}

// Certification model
class Certification {
  String title;
  String issuer;
  String year;

  Certification({
    required this.title,
    required this.issuer,
    required this.year,
  });
}

// Award model
class Award {
  String title;
  String description;
  String year;

  Award({
    required this.title,
    required this.description,
    required this.year,
  });
}
