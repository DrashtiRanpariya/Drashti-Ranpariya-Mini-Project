// lib/cvtemplates/sample_cv_template_screen.dart
//
// Sample CV template screen — uses local fallback/sample values for display
// and PDF export WITHOUT writing those defaults back into the shared CVData.

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class SampleCvTemplateScreen extends StatefulWidget {
  const SampleCvTemplateScreen({super.key});

  @override
  State<SampleCvTemplateScreen> createState() => _SampleCvTemplateScreenState();
}

class _SampleCvTemplateScreenState extends State<SampleCvTemplateScreen>
    with SingleTickerProviderStateMixin {
  final CVData cv = CVData(); // singleton instance (read-only here)

  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  // local fallback/sample values (used only locally, not written to CVData)
  final String _sampleName = 'Aman Patel';
  final String _sampleTitle = 'Software Engineer | Mobile & Web';
  final String _sampleSummary =
      'Goal-driven developer with hands-on experience building full-stack applications using Flutter, Dart, Node.js and relational databases. Strong communicator and collaborative team player.';

  final List<Map<String, String>> _sampleEducation = [
    {
      'degree': 'B.Tech Computer Engineering',
      'field': 'Computer Science',
      'school': 'Nirma University',
      'startYear': '2020',
      'endYear': '2024',
      'duration': '2020 - 2024',
      'details': 'CGPA: 8.6/10',
    }
  ];

  final List<String> _sampleTechnicalSkills = ['Flutter & Dart', 'React & JavaScript', 'Node.js', 'REST APIs', 'SQL'];
  final List<String> _sampleSoftSkills = ['Problem Solving', 'Teamwork', 'Communication'];
  final List<String> _sampleLanguages = ['English (Professional)', 'Hindi (Native)'];
  final List<String> _sampleTools = ['Git', 'Docker', 'Firebase', 'PostgreSQL'];

  final List<Map<String, String>> _sampleProjects = [
    {'title': 'SmartShop - E-commerce App', 'description': 'Flutter app with Firebase backend, product listing, cart and checkout.'},
    {'title': 'Portfolio Website', 'description': 'Responsive portfolio built with React and hosted on GitHub Pages.'},
  ];

  final List<Map<String, String>> _sampleExperience = [
    {
      'role': 'Junior Developer',
      'company': 'TechEdge',
      'year': '2023 - Present',
      'duration': '2023 - Present',
      'description': 'Worked on cross-platform mobile features and backend integrations.'
    }
  ];

  final List<String> _sampleResponsibilities = [
    'Designed and implemented mobile screens using Flutter.',
    'Collaborated with backend team to integrate REST APIs.',
    'Wrote unit tests and assisted in code reviews.',
  ];

  final List<Certification> _sampleCerts = [
    Certification(title: 'Flutter Bootcamp', issuer: 'Udemy', year: '2023'),
    Certification(title: 'Web Development', issuer: 'Coursera', year: '2022'),
  ];

  final List<Award> _sampleAwards = [
    Award(title: 'Best Project', description: 'Hackathon winner', year: '2022'),
  ];

  final List<String> _sampleHobbies = ['Reading', 'Open-source contributions', 'Sketching'];
  final List<String> _samplePublications = ['Example Research Paper — 2024'];
  final List<String> _sampleConferences = ['Presented at ExampleConf 2024'];
  final List<String> _sampleReferences = ['Prof. X — x@example.edu'];
  final List<String> _sampleResearch = ['Research Assistant on ABC project (2022)'];
  final List<String> _sampleDev = ['Completed Advanced Flutter course (2024)'];
  final List<String> _sampleTeaching = ['Guest lecturer — Mobile Dev Workshop (2023)'];
  final List<String> _sampleGrants = ['Research grant: ABC Foundation (2022)'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------- helpers (local-only, do NOT mutate cv) ----------
  String _orLocal(String value, String fallback) => value.trim().isEmpty ? fallback : value.trim();

  List<T> _mergedList<T>(List<T> actual, List<T> fallback) => actual.isEmpty ? fallback : actual;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 6),
      child: Row(children: [
        Container(width: 4, height: 18, color: Colors.blue[800]),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.blueAccent)),
        const Expanded(child: SizedBox())
      ]),
    );
  }

  Widget _text(String text, {bool isSub = false}) {
    return Padding(padding: EdgeInsets.only(bottom: 6, left: isSub ? 12 : 0), child: Text(text, style: TextStyle(fontSize: isSub ? 14 : 15)));
  }

  Widget _bulletList(List<String> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: items.map((i) => _text('• $i')).toList());
  }

  // ---------- PDF generation (uses local merged data) ----------
  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final titleColor = PdfColors.blue800;
    final textGrey = PdfColors.grey700;

    pw.Widget pdfSectionTitle(String title) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 10, bottom: 6),
        child: pw.Row(children: [
          pw.Container(width: 4, height: 16, color: titleColor),
          pw.SizedBox(width: 8),
          pw.Text(title, style: pw.TextStyle(fontSize: 13.5, fontWeight: pw.FontWeight.bold, color: titleColor)),
          pw.Expanded(child: pw.Container(margin: const pw.EdgeInsets.only(left: 8), height: 1, color: PdfColors.grey300))
        ]),
      );
    }

    pw.Widget pdfBulletList(List<String> items) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: items.map((i) => pw.Bullet(text: i)).toList());

    // Local merged values (no writes to cv)
    final String name = _orLocal(cv.name, _sampleName);
    final String title = cv.professionalSummary.trim().isNotEmpty ? cv.professionalSummary : _sampleTitle;
    final String summary = _orLocal(cv.professionalSummary, _sampleSummary);
    final String email = _orLocal(cv.email, 'aman.patel@example.com');
    final String phone = _orLocal(cv.phone, '+91 98765 43210');
    final String address = _orLocal(cv.address, 'City, State, Country');
    final String linkedin = _orLocal(cv.linkedin, '');
    final String github = _orLocal(cv.github, '');
    final String website = _orLocal(cv.website, '');

    final List<Map<String, String>> education = List<Map<String, String>>.from(_mergedList<Map<String, String>>(cv.education, _sampleEducation));
    final List<String> technicalSkills = List<String>.from(_mergedList<String>(cv.technicalSkills, _sampleTechnicalSkills));
    final List<String> softSkills = List<String>.from(_mergedList<String>(cv.softSkills, _sampleSoftSkills));
    final List<String> languages = List<String>.from(_mergedList<String>(cv.languages, _sampleLanguages));
    final List<String> toolsTechnologies = List<String>.from(_mergedList<String>(cv.toolsTechnologies, _sampleTools));
    final List<Map<String, String>> projects = List<Map<String, String>>.from(_mergedList<Map<String, String>>(cv.projects, _sampleProjects));
    final List<Map<String, String>> experience = List<Map<String, String>>.from(_mergedList<Map<String, String>>(cv.experience, _sampleExperience));
    final List<String> responsibilities = List<String>.from(_mergedList<String>(cv.responsibilities, _sampleResponsibilities));
    final List<Certification> certifications = _mergedList<Certification>(cv.certifications, _sampleCerts);
    final List<Award> awards = _mergedList<Award>(cv.awards, _sampleAwards);
    final List<String> hobbies = List<String>.from(_mergedList<String>(cv.hobbies, _sampleHobbies));
    final List<String> publications = List<String>.from(_mergedList<String>(cv.publications, _samplePublications));
    final List<String> conferences = List<String>.from(_mergedList<String>(cv.conferences, _sampleConferences));
    final List<String> references = List<String>.from(_mergedList<String>(cv.references, _sampleReferences));
    final List<String> researchExperiences = List<String>.from(_mergedList<String>(cv.researchExperiences, _sampleResearch));
    final List<String> professionalDevelopments = List<String>.from(_mergedList<String>(cv.professionalDevelopments, _sampleDev));
    final List<String> teachingExperiences = List<String>.from(_mergedList<String>(cv.teachingExperiences, _sampleTeaching));
    final List<String> grants = List<String>.from(_mergedList<String>(cv.grants, _sampleGrants));

    // Build PDF using merged data...
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 28, 36, 28),
        build: (context) => [
          // Header
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(
              width: 72,
              height: 72,
              decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(color: titleColor, width: 2)),
              child: pw.Center(child: pw.Text(_initials(name), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: titleColor))),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(name, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: titleColor)),
                pw.SizedBox(height: 4),
                pw.Text(title, style: pw.TextStyle(fontSize: 11.5, color: textGrey)),
                pw.SizedBox(height: 6),
                pw.Text(summary, style: pw.TextStyle(fontSize: 10.5)),
                pw.SizedBox(height: 8),
                pw.Text('📧 $email   •   📞 $phone   •   📍 $address', style: pw.TextStyle(color: textGrey, fontSize: 9)),
                if (linkedin.isNotEmpty) pw.Text('LinkedIn: $linkedin', style: pw.TextStyle(color: textGrey, fontSize: 9)),
                if (github.isNotEmpty) pw.Text('GitHub: $github', style: pw.TextStyle(color: textGrey, fontSize: 9)),
                if (website.isNotEmpty) pw.Text('Website: $website', style: pw.TextStyle(color: textGrey, fontSize: 9)),
              ]),
            )
          ]),
          pw.SizedBox(height: 12),

          if (education.isNotEmpty) pdfSectionTitle('Education'),
          if (education.isNotEmpty)
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: education.map((e) {
              final deg = e['degree'] ?? e['title'] ?? 'Degree';
              final school = e['school'] ?? '';
              final duration = e['duration'] ?? e['startYear'] ?? '';
              final details = e['details'] ?? '';
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(deg + (school.isNotEmpty ? ' — $school' : ''), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  if (duration.isNotEmpty || details.isNotEmpty) pw.Text((duration.isNotEmpty ? duration : '') + (details.isNotEmpty ? ' • $details' : ''), style: pw.TextStyle(color: textGrey)),
                ]),
              );
            }).toList()),

          if (technicalSkills.isNotEmpty) pdfSectionTitle('Technical Skills'),
          if (technicalSkills.isNotEmpty) pdfBulletList(technicalSkills),
          if (softSkills.isNotEmpty) pdfSectionTitle('Soft Skills'),
          if (softSkills.isNotEmpty) pdfBulletList(softSkills),
          if (toolsTechnologies.isNotEmpty) pdfSectionTitle('Tools & Technologies'),
          if (toolsTechnologies.isNotEmpty) pdfBulletList(toolsTechnologies),

          if (projects.isNotEmpty) pdfSectionTitle('Projects'),
          if (projects.isNotEmpty)
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: projects.map((p) {
              final t = p['title'] ?? 'Project';
              final d = p['description'] ?? p['desc'] ?? '';
              return pw.Container(margin: const pw.EdgeInsets.only(bottom: 6), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('• $t', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (d.isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(left: 8, top: 2), child: pw.Text(d)),
              ]));
            }).toList()),

          if (experience.isNotEmpty) pdfSectionTitle('Experience'),
          if (experience.isNotEmpty)
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: experience.map((e) {
              final role = e['role'] ?? '';
              final company = e['company'] ?? '';
              final year = e['year'] ?? e['duration'] ?? '';
              final desc = e['description'] ?? e['desc'] ?? '';
              return pw.Container(margin: const pw.EdgeInsets.only(bottom: 6), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('${role.isNotEmpty ? role + ' — ' : ''}$company', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (year.isNotEmpty) pw.Text(year, style: pw.TextStyle(color: textGrey)),
                if (desc.isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(left: 6, top: 4), child: pw.Text(desc)),
              ]));
            }).toList()),

          if (responsibilities.isNotEmpty) pdfSectionTitle('Responsibilities / Achievements'),
          if (responsibilities.isNotEmpty) pdfBulletList(responsibilities),

          if (certifications.isNotEmpty) pdfSectionTitle('Certifications'),
          if (certifications.isNotEmpty) pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: certifications.map((c) => pw.Text('• ${c.title} — ${c.issuer} (${c.year})')).toList()),

          if (awards.isNotEmpty) pdfSectionTitle('Awards'),
          if (awards.isNotEmpty) pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: awards.map((a) => pw.Text('• ${a.title} (${a.year}) — ${a.description}')).toList()),

          if (publications.isNotEmpty) pdfSectionTitle('Publications'),
          if (publications.isNotEmpty) pdfBulletList(publications),

          if (conferences.isNotEmpty) pdfSectionTitle('Conferences'),
          if (conferences.isNotEmpty) pdfBulletList(conferences),

          if (researchExperiences.isNotEmpty) pdfSectionTitle('Research Experiences'),
          if (researchExperiences.isNotEmpty) pdfBulletList(researchExperiences),

          if (professionalDevelopments.isNotEmpty) pdfSectionTitle('Professional Development'),
          if (professionalDevelopments.isNotEmpty) pdfBulletList(professionalDevelopments),

          if (teachingExperiences.isNotEmpty) pdfSectionTitle('Teaching Experiences'),
          if (teachingExperiences.isNotEmpty) pdfBulletList(teachingExperiences),

          if (grants.isNotEmpty) pdfSectionTitle('Grants'),
          if (grants.isNotEmpty) pdfBulletList(grants),

          if (languages.isNotEmpty) pdfSectionTitle('Languages'),
          if (languages.isNotEmpty) pdfBulletList(languages),

          if (hobbies.isNotEmpty) pdfSectionTitle('Hobbies & Interests'),
          if (hobbies.isNotEmpty) pdfBulletList(hobbies),

          if (references.isNotEmpty) pdfSectionTitle('References'),
          if (references.isNotEmpty) pdfBulletList(references),

          pw.SizedBox(height: 12),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 6),
          pw.Text('LinkedIn: $linkedin ${github.isNotEmpty ? ' • GitHub: $github' : ''} ${website.isNotEmpty ? ' • Website: $website' : ''}', style: pw.TextStyle(color: textGrey, fontSize: 9)),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // ---------- Build UI (uses merged values locally) ----------
  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width > 1100 ? 1100 : MediaQuery.of(context).size.width - 24;

    final String name = _orLocal(cv.name, _sampleName);
    final String title = cv.professionalSummary.trim().isNotEmpty ? cv.professionalSummary : _sampleTitle;
    final String summary = _orLocal(cv.professionalSummary, _sampleSummary);
    final String email = _orLocal(cv.email, 'aman.patel@example.com');
    final String phone = _orLocal(cv.phone, '+91 98765 43210');
    final String address = _orLocal(cv.address, 'City, State, Country');
    final String linkedin = _orLocal(cv.linkedin, '');
    final String github = _orLocal(cv.github, '');
    final String website = _orLocal(cv.website, '');

    final List<Map<String, String>> education = List<Map<String, String>>.from(_mergedList<Map<String, String>>(cv.education, _sampleEducation));
    final List<String> technicalSkills = List<String>.from(_mergedList<String>(cv.technicalSkills, _sampleTechnicalSkills));
    final List<String> softSkills = List<String>.from(_mergedList<String>(cv.softSkills, _sampleSoftSkills));
    final List<String> languages = List<String>.from(_mergedList<String>(cv.languages, _sampleLanguages));
    final List<String> toolsTechnologies = List<String>.from(_mergedList<String>(cv.toolsTechnologies, _sampleTools));
    final List<Map<String, String>> projects = List<Map<String, String>>.from(_mergedList<Map<String, String>>(cv.projects, _sampleProjects));
    final List<Map<String, String>> experience = List<Map<String, String>>.from(_mergedList<Map<String, String>>(cv.experience, _sampleExperience));
    final List<String> responsibilities = List<String>.from(_mergedList<String>(cv.responsibilities, _sampleResponsibilities));
    final List<Certification> certifications = _mergedList<Certification>(cv.certifications, _sampleCerts);
    final List<Award> awards = _mergedList<Award>(cv.awards, _sampleAwards);
    final List<String> hobbies = List<String>.from(_mergedList<String>(cv.hobbies, _sampleHobbies));
    final List<String> publications = List<String>.from(_mergedList<String>(cv.publications, _samplePublications));
    final List<String> conferences = List<String>.from(_mergedList<String>(cv.conferences, _sampleConferences));
    final List<String> references = List<String>.from(_mergedList<String>(cv.references, _sampleReferences));
    final List<String> researchExperiences = List<String>.from(_mergedList<String>(cv.researchExperiences, _sampleResearch));
    final List<String> professionalDevelopments = List<String>.from(_mergedList<String>(cv.professionalDevelopments, _sampleDev));
    final List<String> teachingExperiences = List<String>.from(_mergedList<String>(cv.teachingExperiences, _sampleTeaching));
    final List<String> grants = List<String>.from(_mergedList<String>(cv.grants, _sampleGrants));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sample CV Template (Full)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        foregroundColor: Colors.white, // ensures title & icons in appBar are white
        actions: [
          IconButton(
            tooltip: 'Download PDF',
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _generatePdf,
          )
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Center(
              child: Container(
                width: maxWidth,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue, width: 2),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.06), offset: const Offset(0, 6), blurRadius: 18)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Header
                  Row(children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blue, width: 2)),
                      child: Center(child: Text(_initials(name), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Text(summary, style: const TextStyle(fontSize: 14, height: 1.4)),
                        const SizedBox(height: 8),
                        Text('📧 $email   •   📞 $phone   •   📍 $address', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 6),
                        if (linkedin.isNotEmpty || github.isNotEmpty || website.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.link, color: Colors.blue),
                            label: const Text('LinkedIn / GitHub / Website', style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                          ),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 8),

                  // Education
                  if (education.isNotEmpty) _sectionTitle('Education'),
                  if (education.isNotEmpty)
                    ...education.map((e) {
                      final deg = e['degree'] ?? e['title'] ?? 'Degree';
                      final school = e['school'] ?? '';
                      final duration = e['duration'] ?? e['startYear'] ?? '';
                      final details = e['details'] ?? '';
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _text(deg),
                        _text('$school • $duration', isSub: true),
                        if (details.isNotEmpty) _text(details, isSub: true),
                        const SizedBox(height: 6),
                      ]);
                    }),

                  // Skills & Tools
                  if (technicalSkills.isNotEmpty) _sectionTitle('Technical Skills'),
                  if (technicalSkills.isNotEmpty) _bulletList(technicalSkills),
                  if (softSkills.isNotEmpty) _sectionTitle('Soft Skills'),
                  if (softSkills.isNotEmpty) _bulletList(softSkills),
                  if (toolsTechnologies.isNotEmpty) _sectionTitle('Tools & Technologies'),
                  if (toolsTechnologies.isNotEmpty) _bulletList(toolsTechnologies),

                  // Projects
                  if (projects.isNotEmpty) _sectionTitle('Projects'),
                  if (projects.isNotEmpty)
                    ...projects.map((p) {
                      final t = p['title'] ?? 'Project';
                      final d = p['description'] ?? p['desc'] ?? '';
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _text('• $t'),
                        if (d.isNotEmpty) _text(d, isSub: true),
                      ]);
                    }),

                  // Experience
                  if (experience.isNotEmpty) _sectionTitle('Experience'),
                  if (experience.isNotEmpty)
                    ...experience.map((e) {
                      final role = e['role'] ?? '';
                      final company = e['company'] ?? '';
                      final year = e['year'] ?? e['duration'] ?? '';
                      final desc = e['description'] ?? e['desc'] ?? '';
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _text('${role.isNotEmpty ? role + ' — ' : ''}$company'),
                        if (year.isNotEmpty) _text(year, isSub: true),
                        if (desc.isNotEmpty) _text(desc, isSub: true),
                        const SizedBox(height: 6),
                      ]);
                    }),

                  // Responsibilities
                  if (responsibilities.isNotEmpty) _sectionTitle('Responsibilities / Achievements'),
                  if (responsibilities.isNotEmpty) _bulletList(responsibilities),

                  // Certifications & Awards
                  if (certifications.isNotEmpty) _sectionTitle('Certifications'),
                  if (certifications.isNotEmpty) ...certifications.map((c) => _text('• ${c.title} — ${c.issuer} (${c.year})')),

                  if (awards.isNotEmpty) _sectionTitle('Awards'),
                  if (awards.isNotEmpty) ...awards.map((a) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _text('• ${a.title} (${a.year})'),
                    if (a.description.isNotEmpty) _text(a.description, isSub: true),
                  ])),

                  // Publications / Conferences / Research
                  if (publications.isNotEmpty) _sectionTitle('Publications'),
                  if (publications.isNotEmpty) _bulletList(publications),

                  if (conferences.isNotEmpty) _sectionTitle('Conferences'),
                  if (conferences.isNotEmpty) _bulletList(conferences),

                  if (researchExperiences.isNotEmpty) _sectionTitle('Research Experiences'),
                  if (researchExperiences.isNotEmpty) _bulletList(researchExperiences),

                  if (professionalDevelopments.isNotEmpty) _sectionTitle('Professional Development'),
                  if (professionalDevelopments.isNotEmpty) _bulletList(professionalDevelopments),

                  if (teachingExperiences.isNotEmpty) _sectionTitle('Teaching Experiences'),
                  if (teachingExperiences.isNotEmpty) _bulletList(teachingExperiences),

                  if (grants.isNotEmpty) _sectionTitle('Grants'),
                  if (grants.isNotEmpty) _bulletList(grants),

                  // Languages & Hobbies & References
                  if (languages.isNotEmpty) _sectionTitle('Languages'),
                  if (languages.isNotEmpty) _bulletList(languages),

                  if (hobbies.isNotEmpty) _sectionTitle('Hobbies & Interests'),
                  if (hobbies.isNotEmpty) _bulletList(hobbies),

                  if (references.isNotEmpty) _sectionTitle('References'),
                  if (references.isNotEmpty) _bulletList(references),

                  const SizedBox(height: 12),
                ]),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Download PDF',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white, // ensures any default text/icon becomes white
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
