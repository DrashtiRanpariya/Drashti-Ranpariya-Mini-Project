import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class CVTemplate4Screen extends StatefulWidget {
  const CVTemplate4Screen({super.key});

  @override
  State<CVTemplate4Screen> createState() => _CVTemplate4ScreenState();
}

class _CVTemplate4ScreenState extends State<CVTemplate4Screen> with SingleTickerProviderStateMixin {
  final cvData = CVData();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget bulletList(List<String> items, {Color textColor = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
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

  Widget sidebarItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget sectionCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  // ---------------- PDF generation ----------------
  Future<void> _generatePdf() async {
    final doc = pw.Document();
    final titleColor = PdfColors.deepPurple800;
    final grey = PdfColors.grey700;

    pw.Widget pdfSectionTitle(String title) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8, bottom: 6),
        child: pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: titleColor)),
      );
    }

    pw.Widget pdfBulletList(List<String> items) {
      if (items.isEmpty) return pw.SizedBox();
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((e) => pw.Bullet(text: e)).toList(),
      );
    }

    // helper to render maps
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
              pw.Text('$school ($start - $end)', style: pw.TextStyle(color: grey)),
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
              pw.Text('Year: $year', style: pw.TextStyle(color: grey)),
              if (details.isNotEmpty) pw.Text(details),
            ]),
          );
        } else if (type == 'projects') {
          final title = m['title'] ?? '';
          final desc = m['description'] ?? '';
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              if (desc.isNotEmpty) pw.Text(desc, style: pw.TextStyle(color: grey)),
            ]),
          );
        } else {
          return pw.SizedBox();
        }
      }).toList();
    }

    // Build a multi-page PDF with a sidebar-like header row on each page
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            // Top header row: left "sidebar" column and right main column
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              // Sidebar column (fixed width)
              pw.Container(
                width: 140,
                padding: const pw.EdgeInsets.only(right: 12),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  // Initial circle
                  pw.Container(
                    width: 72,
                    height: 72,
                    decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: PdfColors.deepPurple),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      cvData.name.isNotEmpty ? cvData.name[0].toUpperCase() : 'U',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 28, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  if (cvData.email.isNotEmpty) pw.Text(cvData.email, style: pw.TextStyle(color: grey)),
                  if (cvData.phone.isNotEmpty) pw.Text(cvData.phone, style: pw.TextStyle(color: grey)),
                  if (cvData.linkedin.isNotEmpty) pw.Text('LinkedIn: ${cvData.linkedin}', style: pw.TextStyle(color: grey)),
                  if (cvData.github.isNotEmpty) pw.Text('GitHub: ${cvData.github}', style: pw.TextStyle(color: grey)),
                  if (cvData.address.isNotEmpty) pw.Text(cvData.address, style: pw.TextStyle(color: grey)),
                  pw.SizedBox(height: 12),

                  // Skills
                  if (cvData.technicalSkills.isNotEmpty) pw.Column(children: [
                    pw.Text('Skills', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pdfBulletList(cvData.technicalSkills),
                  ]),

                  pw.SizedBox(height: 8),

                  // Languages
                  if (cvData.languages.isNotEmpty) pw.Column(children: [
                    pw.Text('Languages', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pdfBulletList(cvData.languages),
                  ]),

                  pw.SizedBox(height: 8),

                  // Tools
                  if (cvData.toolsTechnologies.isNotEmpty) pw.Column(children: [
                    pw.Text('Tools', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pdfBulletList(cvData.toolsTechnologies),
                  ]),
                ]),
              ),

              // Main column (expand)
              pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                // Name + role
                if (cvData.name.isNotEmpty)
                  pw.Text(cvData.name, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: titleColor)),
                pw.SizedBox(height: 6),
                if (cvData.professionalSummary.isNotEmpty) ...[
                  pdfSectionTitle('Professional Summary'),
                  pw.Text(cvData.professionalSummary),
                ],

                if (cvData.education.isNotEmpty) ...[
                  pdfSectionTitle('Education'),
                  ...buildMapList(cvData.education, 'education'),
                ],

                if (cvData.experience.isNotEmpty) ...[
                  pdfSectionTitle('Experience'),
                  ...buildMapList(cvData.experience, 'experience'),
                ],

                if (cvData.projects.isNotEmpty) ...[
                  pdfSectionTitle('Projects'),
                  ...buildMapList(cvData.projects, 'projects'),
                ],

                if (cvData.certifications.isNotEmpty) ...[
                  pdfSectionTitle('Certifications'),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:
                  cvData.certifications.map((c) => pw.Text('${c.title} — ${c.issuer} (${c.year})')).toList()
                  ),
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
                ],

                if (cvData.publications.isNotEmpty) ...[
                  pdfSectionTitle('Publications'),
                  pdfBulletList(cvData.publications),
                ],

                if (cvData.conferences.isNotEmpty) ...[
                  pdfSectionTitle('Conferences / Workshops'),
                  pdfBulletList(cvData.conferences),
                ],

                if (cvData.researchExperiences.isNotEmpty) ...[
                  pdfSectionTitle('Research Experience'),
                  pdfBulletList(cvData.researchExperiences),
                ],

                if (cvData.teachingExperiences.isNotEmpty) ...[
                  pdfSectionTitle('Teaching Experience'),
                  pdfBulletList(cvData.teachingExperiences),
                ],

                if (cvData.professionalDevelopments.isNotEmpty) ...[
                  pdfSectionTitle('Professional Development'),
                  pdfBulletList(cvData.professionalDevelopments),
                ],

                if (cvData.grants.isNotEmpty) ...[
                  pdfSectionTitle('Grants / Funding'),
                  pdfBulletList(cvData.grants),
                ],

                if (cvData.references.isNotEmpty) ...[
                  pdfSectionTitle('References'),
                  pdfBulletList(cvData.references),
                ],

                if (cvData.hobbies.isNotEmpty) ...[
                  pdfSectionTitle('Hobbies / Interests'),
                  pdfBulletList(cvData.hobbies),
                ],
              ])),
            ]), // end row
          ];
        },
      ),
    );

    // Open native preview (Print / Save / Share)
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Template 4'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            tooltip: 'Export as PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Sidebar
            Container(
              width: 200,
              color: Colors.deepPurple.shade700,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      cvData.name.isNotEmpty ? cvData.name[0].toUpperCase() : "U",
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(cvData.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const Divider(color: Colors.white38, thickness: 1, height: 20),
                  if (cvData.email.isNotEmpty) sidebarItem(Icons.email, cvData.email),
                  if (cvData.phone.isNotEmpty) sidebarItem(Icons.phone, cvData.phone),
                  if (cvData.linkedin.isNotEmpty) sidebarItem(Icons.link, cvData.linkedin),
                  if (cvData.github.isNotEmpty) sidebarItem(Icons.code, cvData.github),
                  const Divider(color: Colors.white38, thickness: 1, height: 20),
                  if (cvData.technicalSkills.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("💻 Skills", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        // show skills as simple bullets
                        for (var s in cvData.technicalSkills)
                          Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text("• $s", style: const TextStyle(color: Colors.white))),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (cvData.languages.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("🗣 Languages", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        for (var l in cvData.languages)
                          Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text("• $l", style: const TextStyle(color: Colors.white))),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (cvData.toolsTechnologies.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("🛠 Tools", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        for (var t in cvData.toolsTechnologies)
                          Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text("• $t", style: const TextStyle(color: Colors.white))),
                      ],
                    ),
                ],
              ),
            ),

            // Right Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Professional Summary
                    if (cvData.professionalSummary.isNotEmpty)
                      sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("📝", "Professional Summary"),
                            const SizedBox(height: 6),
                            Text(cvData.professionalSummary),
                          ],
                        ),
                      ),

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
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    "${edu['degree']} in ${edu['field']} - ${edu['school']} (${edu['startYear']} - ${edu['endYear']})",
                                  ),
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
                                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text("${proj['title']}: ${proj['description']}"),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                    // Certifications
                    if (cvData.certifications.isNotEmpty)
                      sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("🏅", "Certifications"),
                            const SizedBox(height: 6),
                            Column(
                              children: cvData.certifications.map((c) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text("${c.title} (${c.year}) - ${c.issuer}"),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),

                    // Awards
                    if (cvData.awards.isNotEmpty)
                      sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("🏆", "Awards & Honors"),
                            const SizedBox(height: 6),
                            Column(
                              children: cvData.awards.map((a) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text("${a.title} (${a.year}) - ${a.description}"),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),

                    // Publications
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

                    // Conferences / Workshops
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

                    // Research Experience
                    if (cvData.researchExperiences.isNotEmpty)
                      sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("🔬", "Research Experience"),
                            const SizedBox(height: 6),
                            bulletList(cvData.researchExperiences),
                          ],
                        ),
                      ),

                    // Professional Development
                    if (cvData.professionalDevelopments.isNotEmpty)
                      sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("📖", "Professional Development"),
                            const SizedBox(height: 6),
                            bulletList(cvData.professionalDevelopments),
                          ],
                        ),
                      ),

                    // Teaching Experience
                    if (cvData.teachingExperiences.isNotEmpty)
                      sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("📚", "Teaching Experience"),
                            const SizedBox(height: 6),
                            bulletList(cvData.teachingExperiences),
                          ],
                        ),
                      ),

                    // Grants / Funding
                    if (cvData.grants.isNotEmpty)
                      sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("💰", "Grants / Funding"),
                            const SizedBox(height: 6),
                            bulletList(cvData.grants),
                          ],
                        ),
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            )
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
                backgroundColor: Colors.deepPurple,
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
