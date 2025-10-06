import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class CVTemplate2Screen extends StatefulWidget {
  const CVTemplate2Screen({super.key});

  @override
  State<CVTemplate2Screen> createState() => _CVTemplate2ScreenState();
}

class _CVTemplate2ScreenState extends State<CVTemplate2Screen> with SingleTickerProviderStateMixin {
  final cvData = CVData();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget sectionTitle(String emoji, String title, Color color) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget bulletList(List<String> items, {Color textColor = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ", style: TextStyle(fontSize: 16)),
            Expanded(child: Text(e, style: TextStyle(color: textColor))),
          ],
        ),
      )).toList(),
    );
  }

  Widget gradientCard({required Widget child, required List<Color> gradientColors}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }

  Widget sectionCard({required String emoji, required String title, required Widget child, required List<Color> colors}) {
    return gradientCard(
      gradientColors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle(emoji, title, Colors.white),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  // ---------------- PDF generation ----------------
  Future<void> _generatePdf() async {
    final doc = pw.Document();
    final titleColor = PdfColors.teal800;
    final textGrey = PdfColors.grey700;

    pw.Widget pdfSectionTitle(String title) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 10, bottom: 6),
        child: pw.Text(title,
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold, color: titleColor)),
      );
    }

    pw.Widget pdfBulletList(List<String> items) {
      if (items.isEmpty) return pw.SizedBox();
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((e) => pw.Bullet(text: e)).toList(),
      );
    }

    List<pw.Widget> buildMapList(List<Map<String, String>> maps, String type) {
      return maps.map((m) {
        if (type == 'education') {
          final degree = m['degree'] ?? '';
          final field = m['field'] ?? '';
          final school = m['school'] ?? '';
          final start = m['startYear'] ?? '';
          final end = m['endYear'] ?? '';
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('$degree in $field', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('$school ($start - $end)'),
            ]),
          );
        } else if (type == 'projects') {
          final title = m['title'] ?? '';
          final desc = m['description'] ?? '';
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              if (desc.isNotEmpty) pw.Text(desc),
            ]),
          );
        } else if (type == 'experience') {
          final role = m['role'] ?? '';
          final company = m['company'] ?? '';
          final year = m['year'] ?? '';
          final details = m['details'] ?? '';
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('$role at $company', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Year: $year'),
              if (details.isNotEmpty) pw.Text(details),
            ]),
          );
        } else {
          return pw.SizedBox();
        }
      }).toList();
    }

    // Build the PDF as a MultiPage
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            // Header: emulate gradient header by colored title block + initial circle
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Initial circle (since CVData has no image)
                  pw.Container(
                    width: 64,
                    height: 64,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: PdfColors.teal,
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      cvData.name.isNotEmpty ? cvData.name[0].toUpperCase() : 'U',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 28, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    if (cvData.name.isNotEmpty)
                      pw.Text(cvData.name, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: titleColor)),
                    pw.SizedBox(height: 6),
                    pw.Wrap(spacing: 8, runSpacing: 4, children: [
                      if (cvData.email.isNotEmpty) pw.Text('Email: ${cvData.email}', style: pw.TextStyle(color: textGrey)),
                      if (cvData.phone.isNotEmpty) pw.Text('Phone: ${cvData.phone}', style: pw.TextStyle(color: textGrey)),
                      if (cvData.linkedin.isNotEmpty) pw.Text('LinkedIn: ${cvData.linkedin}', style: pw.TextStyle(color: textGrey)),
                    ]),
                  ])),
                ],
              ),
            ),

            // Professional Summary
            if (cvData.professionalSummary.isNotEmpty) ...[
              pdfSectionTitle('Professional Summary'),
              pw.Text(cvData.professionalSummary),
            ],

            // Skills
            if (cvData.technicalSkills.isNotEmpty || cvData.softSkills.isNotEmpty) ...[
              pdfSectionTitle('Skills'),
              if (cvData.technicalSkills.isNotEmpty) pdfBulletList(cvData.technicalSkills),
              if (cvData.softSkills.isNotEmpty) pdfBulletList(cvData.softSkills),
            ],

            // Education
            if (cvData.education.isNotEmpty) ...[
              pdfSectionTitle('Education'),
              ...buildMapList(cvData.education, 'education'),
            ],

            // Experience
            if (cvData.experience.isNotEmpty) ...[
              pdfSectionTitle('Experience'),
              ...buildMapList(cvData.experience, 'experience'),
            ],

            // Projects
            if (cvData.projects.isNotEmpty) ...[
              pdfSectionTitle('Projects'),
              ...buildMapList(cvData.projects, 'projects'),
            ],

            // Certifications
            if (cvData.certifications.isNotEmpty) ...[
              pdfSectionTitle('Certifications'),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:
              cvData.certifications.map((c) => pw.Text('${c.title} — ${c.issuer} (${c.year})')).toList()
              ),
            ],

            // Awards
            if (cvData.awards.isNotEmpty) ...[
              pdfSectionTitle('Awards & Honors'),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:
              cvData.awards.map((a) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('${a.title} — ${a.year}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (a.description.isNotEmpty) pw.Text(a.description),
                pw.SizedBox(height: 6),
              ])).toList()
              ),
            ],

            // Publications
            if (cvData.publications.isNotEmpty) ...[
              pdfSectionTitle('Publications'),
              pdfBulletList(cvData.publications),
            ],

            // Conferences / Workshops
            if (cvData.conferences.isNotEmpty) ...[
              pdfSectionTitle('Conferences / Workshops'),
              pdfBulletList(cvData.conferences),
            ],

            // Research Experience
            if (cvData.researchExperiences.isNotEmpty) ...[
              pdfSectionTitle('Research Experience'),
              pdfBulletList(cvData.researchExperiences),
            ],

            // Teaching Experience
            if (cvData.teachingExperiences.isNotEmpty) ...[
              pdfSectionTitle('Teaching Experience'),
              pdfBulletList(cvData.teachingExperiences),
            ],

            // Professional Development
            if (cvData.professionalDevelopments.isNotEmpty) ...[
              pdfSectionTitle('Professional Development'),
              pdfBulletList(cvData.professionalDevelopments),
            ],

            // Grants / Funding
            if (cvData.grants.isNotEmpty) ...[
              pdfSectionTitle('Grants / Funding'),
              pdfBulletList(cvData.grants),
            ],

            // References
            if (cvData.references.isNotEmpty) ...[
              pdfSectionTitle('References'),
              pdfBulletList(cvData.references),
            ],

            // Hobbies
            if (cvData.hobbies.isNotEmpty) ...[
              pdfSectionTitle('Hobbies / Interests'),
              pdfBulletList(cvData.hobbies),
            ],
          ];
        },
      ),
    );

    // Open system print/save/share UI
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("CV Template 2"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Export as PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header: Name + Email + Profile Picture
            gradientCard(
              gradientColors: [Colors.teal, Colors.tealAccent],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cvData.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        if (cvData.email.isNotEmpty) Text("📧 ${cvData.email}", style: const TextStyle(color: Colors.white)),
                        if (cvData.phone.isNotEmpty) Text("📞 ${cvData.phone}", style: const TextStyle(color: Colors.white)),
                        if (cvData.linkedin.isNotEmpty) Text("🔗 ${cvData.linkedin}", style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile initial placeholder (no image in CVData by default)
                  Expanded(
                    flex: 1,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        cvData.name.isNotEmpty ? cvData.name[0].toUpperCase() : "U",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Professional Summary
            if (cvData.professionalSummary.isNotEmpty)
              sectionCard(
                emoji: "📝",
                title: "Professional Summary",
                child: Text(cvData.professionalSummary, style: const TextStyle(color: Colors.white)),
                colors: [Colors.purpleAccent, Colors.deepPurple],
              ),

            // Skills
            if (cvData.technicalSkills.isNotEmpty || cvData.softSkills.isNotEmpty)
              sectionCard(
                emoji: "💻",
                title: "Skills",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cvData.technicalSkills.isNotEmpty) bulletList(cvData.technicalSkills, textColor: Colors.white),
                    if (cvData.softSkills.isNotEmpty) bulletList(cvData.softSkills, textColor: Colors.white),
                  ],
                ),
                colors: [Colors.orangeAccent, Colors.deepOrange],
              ),

            // Education
            if (cvData.education.isNotEmpty)
              sectionCard(
                emoji: "🎓",
                title: "Education",
                child: Column(
                  children: cvData.education.map((edu) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text("${edu['degree']} in ${edu['field']} - ${edu['school']} (${edu['startYear']} - ${edu['endYear']})",
                          style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
                colors: [Colors.teal, Colors.tealAccent],
              ),

            // Experience
            if (cvData.experience.isNotEmpty)
              sectionCard(
                emoji: "💼",
                title: "Experience",
                child: Column(
                  children: cvData.experience.map((exp) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text("${exp['role']} at ${exp['company']} (${exp['year']})", style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
                colors: [Colors.indigo, Colors.indigoAccent],
              ),

            // Projects
            if (cvData.projects.isNotEmpty)
              sectionCard(
                emoji: "🚀",
                title: "Projects",
                child: Column(
                  children: cvData.projects.map((proj) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text("${proj['title']}: ${proj['description']}", style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
                colors: [Colors.pinkAccent, Colors.redAccent],
              ),

            // Certifications
            if (cvData.certifications.isNotEmpty)
              sectionCard(
                emoji: "🏅",
                title: "Certifications",
                child: Column(
                  children: cvData.certifications.map((c) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text("${c.title} (${c.year}) - ${c.issuer}", style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
                colors: [Colors.greenAccent, Colors.teal],
              ),

            // Awards
            if (cvData.awards.isNotEmpty)
              sectionCard(
                emoji: "🏆",
                title: "Awards & Honors",
                child: Column(
                  children: cvData.awards.map((a) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text("${a.title} (${a.year}) - ${a.description}", style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
                colors: [Colors.amber, Colors.deepOrangeAccent],
              ),

            // Publications
            if (cvData.publications.isNotEmpty)
              sectionCard(
                emoji: "📚",
                title: "Publications",
                child: bulletList(cvData.publications, textColor: Colors.white),
                colors: [Colors.purple, Colors.deepPurpleAccent],
              ),

            // Conferences / Workshops
            if (cvData.conferences.isNotEmpty)
              sectionCard(
                emoji: "🎤",
                title: "Conferences / Workshops",
                child: bulletList(cvData.conferences, textColor: Colors.white),
                colors: [Colors.cyan, Colors.tealAccent],
              ),

            // References
            if (cvData.references.isNotEmpty)
              sectionCard(
                emoji: "👥",
                title: "References",
                child: bulletList(cvData.references, textColor: Colors.white),
                colors: [Colors.blueGrey, Colors.grey],
              ),

            // Research Experience
            if (cvData.researchExperiences.isNotEmpty)
              sectionCard(
                emoji: "🔬",
                title: "Research Experience",
                child: bulletList(cvData.researchExperiences, textColor: Colors.white),
                colors: [Colors.orange, Colors.deepOrangeAccent],
              ),

            // Professional Development
            if (cvData.professionalDevelopments.isNotEmpty)
              sectionCard(
                emoji: "📖",
                title: "Professional Development",
                child: bulletList(cvData.professionalDevelopments, textColor: Colors.white),
                colors: [Colors.pinkAccent, Colors.red],
              ),

            // Teaching Experience
            if (cvData.teachingExperiences.isNotEmpty)
              sectionCard(
                emoji: "📚",
                title: "Teaching Experience",
                child: bulletList(cvData.teachingExperiences, textColor: Colors.white),
                colors: [Colors.teal, Colors.tealAccent],
              ),

            // Grants / Funding
            if (cvData.grants.isNotEmpty)
              sectionCard(
                emoji: "💰",
                title: "Grants / Funding",
                child: bulletList(cvData.grants, textColor: Colors.white),
                colors: [Colors.green, Colors.greenAccent],
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text(
                "Download / Print PDF",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: _generatePdf,
            ),
          ),
        ),
      ),
    );
  }
}
