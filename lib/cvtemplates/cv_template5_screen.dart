import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class CVTemplate5Screen extends StatefulWidget {
  const CVTemplate5Screen({super.key});

  @override
  State<CVTemplate5Screen> createState() => _CVTemplate5ScreenState();
}

class _CVTemplate5ScreenState extends State<CVTemplate5Screen> with SingleTickerProviderStateMixin {
  final cvData = CVData();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

  Widget sectionTitle(String emoji, String title) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ", style: TextStyle(fontSize: 16)),
            Expanded(child: Text(e)),
          ],
        ),
      )).toList(),
    );
  }

  Widget sectionCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }

  // ---------------- PDF generation ----------------
  Future<void> _generatePdf() async {
    final doc = pw.Document();
    final bannerStart = PdfColors.teal800;
    final bannerEnd = PdfColors.teal300;
    final titleColor = PdfColors.black;
    final grey = PdfColors.grey700;

    pw.Widget pdfSectionTitle(String title) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
        child: pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: titleColor)),
      );
    }

    pw.Widget pdfBulletList(List<String> items) {
      if (items.isEmpty) return pw.SizedBox();
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((s) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("• "),
              pw.Expanded(child: pw.Text(s)),
            ],
          ),
        )).toList(),
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
          return pw.Container(margin: const pw.EdgeInsets.only(bottom: 6), child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('$degree in $field', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('$school ($start - $end)', style: pw.TextStyle(color: grey)),
            ],
          ));
        } else if (type == 'experience') {
          final role = m['role'] ?? '';
          final company = m['company'] ?? '';
          final year = m['year'] ?? '';
          final details = m['details'] ?? '';
          return pw.Container(margin: const pw.EdgeInsets.only(bottom: 6), child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('$role at $company', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Year: $year', style: pw.TextStyle(color: grey)),
              if (details.isNotEmpty) pw.Text(details),
            ],
          ));
        } else if (type == 'projects') {
          final title = m['title'] ?? '';
          final desc = m['description'] ?? '';
          return pw.Container(margin: const pw.EdgeInsets.only(bottom: 6), child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              if (desc.isNotEmpty) pw.Text(desc, style: pw.TextStyle(color: grey)),
            ],
          ));
        } else {
          return pw.SizedBox();
        }
      }).toList();
    }

    // Build PDF: header banner + two-column body (left: skills/tools/lang, right: main)
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context ctx) {
          return [
            // Banner
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(colors: [bannerStart, bannerEnd]),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Name + contact
                  pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    if (cvData.name.isNotEmpty)
                      pw.Text(cvData.name, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.SizedBox(height: 6),
                    pw.Wrap(spacing: 8, runSpacing: 4, children: [
                      if (cvData.email.isNotEmpty) pw.Text('📧 ${cvData.email}', style: pw.TextStyle(color: PdfColors.white)),
                      if (cvData.phone.isNotEmpty) pw.Text('📞 ${cvData.phone}', style: pw.TextStyle(color: PdfColors.white)),
                      if (cvData.linkedin.isNotEmpty) pw.Text('🔗 ${cvData.linkedin}', style: pw.TextStyle(color: PdfColors.white)),
                    ]),
                  ])),
                  // initial circle
                  pw.Container(
                    width: 56,
                    height: 56,
                    decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: PdfColors.white),
                    alignment: pw.Alignment.center,
                    child: pw.Text(cvData.name.isNotEmpty ? cvData.name[0].toUpperCase() : 'U',
                        style: pw.TextStyle(color: bannerStart, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 12),

            // Two columns: left sidebar (fixed width) and right main
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              // Left column
              pw.Container(
                width: 160,
                padding: const pw.EdgeInsets.only(right: 12),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  if (cvData.technicalSkills.isNotEmpty) ...[
                    pdfSectionTitle('Technical Skills'),
                    pdfBulletList(cvData.technicalSkills),
                    pw.SizedBox(height: 8),
                  ],
                  if (cvData.languages.isNotEmpty) ...[
                    pdfSectionTitle('Languages'),
                    pdfBulletList(cvData.languages),
                    pw.SizedBox(height: 8),
                  ],
                  if (cvData.toolsTechnologies.isNotEmpty) ...[
                    pdfSectionTitle('Tools & Technologies'),
                    pdfBulletList(cvData.toolsTechnologies),
                    pw.SizedBox(height: 8),
                  ],
                  if (cvData.hobbies.isNotEmpty) ...[
                    pdfSectionTitle('Hobbies'),
                    pdfBulletList(cvData.hobbies),
                    pw.SizedBox(height: 8),
                  ],
                ]),
              ),

              // Right column (expand)
              pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                if (cvData.professionalSummary.isNotEmpty) ...[
                  pdfSectionTitle('Professional Summary'),
                  pw.Text(cvData.professionalSummary),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.education.isNotEmpty) ...[
                  pdfSectionTitle('Education'),
                  ...buildMapList(cvData.education, 'education'),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.experience.isNotEmpty) ...[
                  pdfSectionTitle('Experience'),
                  ...buildMapList(cvData.experience, 'experience'),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.projects.isNotEmpty) ...[
                  pdfSectionTitle('Projects'),
                  ...buildMapList(cvData.projects, 'projects'),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.certifications.isNotEmpty) ...[
                  pdfSectionTitle('Certifications'),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:
                  cvData.certifications.map((c) => pw.Text('${c.title} — ${c.issuer} (${c.year})')).toList()
                  ),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.awards.isNotEmpty) ...[
                  pdfSectionTitle('Awards & Honors'),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:
                  cvData.awards.map((a) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('${a.title} — ${a.year}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    if (a.description.isNotEmpty) pw.Text(a.description),
                    pw.SizedBox(height: 6),
                  ])).toList()
                  ),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.publications.isNotEmpty) ...[
                  pdfSectionTitle('Publications'),
                  pdfBulletList(cvData.publications),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.conferences.isNotEmpty) ...[
                  pdfSectionTitle('Conferences / Workshops'),
                  pdfBulletList(cvData.conferences),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.researchExperiences.isNotEmpty) ...[
                  pdfSectionTitle('Research Experience'),
                  pdfBulletList(cvData.researchExperiences),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.teachingExperiences.isNotEmpty) ...[
                  pdfSectionTitle('Teaching Experience'),
                  pdfBulletList(cvData.teachingExperiences),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.professionalDevelopments.isNotEmpty) ...[
                  pdfSectionTitle('Professional Development'),
                  pdfBulletList(cvData.professionalDevelopments),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.grants.isNotEmpty) ...[
                  pdfSectionTitle('Grants / Funding'),
                  pdfBulletList(cvData.grants),
                  pw.SizedBox(height: 8),
                ],

                if (cvData.references.isNotEmpty) ...[
                  pdfSectionTitle('References'),
                  pdfBulletList(cvData.references),
                ],
              ])),
            ]),
          ];
        },
      ),
    );

    // Show native preview (print / save / share)
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CV Template 5"),
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            tooltip: 'Export as PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade700, Colors.tealAccent.shade700],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      cvData.name.isNotEmpty ? cvData.name : "Your Name",
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    if (cvData.email.isNotEmpty) Text(cvData.email, style: const TextStyle(color: Colors.white70)),
                    if (cvData.phone.isNotEmpty) Text(cvData.phone, style: const TextStyle(color: Colors.white70)),
                    if (cvData.linkedin.isNotEmpty) Text(cvData.linkedin, style: const TextStyle(color: Colors.white70)),
                    if (cvData.github.isNotEmpty) Text(cvData.github, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cvData.technicalSkills.isNotEmpty)
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle("💻", "Technical Skills"),
                                  const SizedBox(height: 6),
                                  bulletList(cvData.technicalSkills),
                                ],
                              ),
                            ),
                          if (cvData.languages.isNotEmpty)
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle("🗣", "Languages"),
                                  const SizedBox(height: 6),
                                  bulletList(cvData.languages),
                                ],
                              ),
                            ),
                          if (cvData.toolsTechnologies.isNotEmpty)
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle("🛠", "Tools & Technologies"),
                                  const SizedBox(height: 6),
                                  bulletList(cvData.toolsTechnologies),
                                ],
                              ),
                            ),
                          if (cvData.hobbies.isNotEmpty)
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle("🎯", "Hobbies"),
                                  const SizedBox(height: 6),
                                  bulletList(cvData.hobbies),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right column
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Education
                          if (cvData.education.isNotEmpty)
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle("🎓", "Education"),
                                  const SizedBox(height: 6),
                                  Column(
                                    children: cvData.education.map((edu) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text("${edu['degree']} in ${edu['field']} - ${edu['school']} (${edu['startYear']} - ${edu['endYear']})"),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                          // Experience
                          if (cvData.experience.isNotEmpty)
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle("💼", "Experience"),
                                  const SizedBox(height: 6),
                                  Column(
                                    children: cvData.experience.map((exp) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text("${exp['role']} at ${exp['company']} (${exp['year']})"),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                          // Projects
                          if (cvData.projects.isNotEmpty)
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle("🚀", "Projects"),
                                  const SizedBox(height: 6),
                                  Column(
                                    children: cvData.projects.map((proj) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text("${proj['title']}: ${proj['description']}"),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                          // Additional Sections
                          if (cvData.certifications.isNotEmpty)
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle("🏅", "Certifications"),
                                  const SizedBox(height: 6),
                                  Column(
                                    children: cvData.certifications.map((c) => Text("${c.title} (${c.year}) - ${c.issuer}")).toList(),
                                  ),
                                ],
                              ),
                            ),

                          if (cvData.awards.isNotEmpty)
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle("🏆", "Awards & Honors"),
                                  const SizedBox(height: 6),
                                  Column(
                                    children: cvData.awards.map((a) => Text("${a.title} (${a.year}) - ${a.description}")).toList(),
                                  ),
                                ],
                              ),
                            ),

                          if (cvData.publications.isNotEmpty)
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle("📚", "Publications"),
                                  const SizedBox(height: 6),
                                  bulletList(cvData.publications),
                                ],
                              ),
                            ),

                          if (cvData.conferences.isNotEmpty)
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle("🎤", "Conferences / Workshops"),
                                  const SizedBox(height: 6),
                                  bulletList(cvData.conferences),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
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
