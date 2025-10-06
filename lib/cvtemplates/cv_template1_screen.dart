import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class CVTemplate1Screen extends StatelessWidget {
  final cvData = CVData();

  CVTemplate1Screen({super.key});

  Widget sectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget bulletList(List<String> items, {Color textColor = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ", style: TextStyle(color: textColor, fontSize: 15)),
              Expanded(child: Text(e, style: TextStyle(color: textColor))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget infoCard({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: child,
    );
  }

  Widget sectionCard({required String title, required IconData icon, required Widget child, Color? color}) {
    return infoCard(
      color: color ?? Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle(title, icon, Colors.blueAccent),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // ---------------- PDF generation ----------------
  Future<void> _generatePdf(BuildContext context) async {
    final doc = pw.Document();
    final titleColor = PdfColors.blue800;
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

    // helper to render map lists (education/projects/experience)
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
              if (details != null && details.isNotEmpty) pw.Text(details),
            ]),
          );
        } else {
          return pw.SizedBox();
        }
      }).toList();
    }

    // Create PDF pages. We'll produce a MultiPage to allow overflow.
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header block
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                if (cvData.name.isNotEmpty)
                  pw.Text(cvData.name, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: titleColor)),
                pw.SizedBox(height: 6),
                pw.Wrap(spacing: 8, children: [
                  if (cvData.email.isNotEmpty) pw.Text('Email: ${cvData.email}', style: pw.TextStyle(color: textGrey)),
                  if (cvData.phone.isNotEmpty) pw.Text('Phone: ${cvData.phone}', style: pw.TextStyle(color: textGrey)),
                  if (cvData.address.isNotEmpty) pw.Text('Address: ${cvData.address}', style: pw.TextStyle(color: textGrey)),
                ]),
                if (cvData.linkedin.isNotEmpty || cvData.github.isNotEmpty || cvData.website.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 6),
                    child: pw.Text(
                      [
                        if (cvData.linkedin.isNotEmpty) 'LinkedIn: ${cvData.linkedin}',
                        if (cvData.github.isNotEmpty) 'GitHub: ${cvData.github}',
                        if (cvData.website.isNotEmpty) 'Website: ${cvData.website}'
                      ].join('  •  '),
                      style: pw.TextStyle(color: textGrey),
                    ),
                  ),
              ]),
            ),

            // Professional summary
            if (cvData.professionalSummary.isNotEmpty) ...[
              pdfSectionTitle('Professional Summary'),
              pw.Text(cvData.professionalSummary),
            ],

            // Skills
            if (cvData.technicalSkills.isNotEmpty ||
                cvData.softSkills.isNotEmpty ||
                cvData.languages.isNotEmpty ||
                cvData.toolsTechnologies.isNotEmpty) ...[
              pdfSectionTitle('Skills'),
              if (cvData.technicalSkills.isNotEmpty) pdfBulletList(cvData.technicalSkills),
              if (cvData.softSkills.isNotEmpty) pdfBulletList(cvData.softSkills),
              if (cvData.languages.isNotEmpty) pdfBulletList(cvData.languages),
              if (cvData.toolsTechnologies.isNotEmpty) pdfBulletList(cvData.toolsTechnologies),
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

            // Responsibilities / Achievements
            if (cvData.responsibilities.isNotEmpty) ...[
              pdfSectionTitle('Responsibilities / Achievements'),
              pdfBulletList(cvData.responsibilities),
            ],

            // Certifications
            if (cvData.certifications.isNotEmpty) ...[
              pdfSectionTitle('Certifications'),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: cvData.certifications.map((c) => pw.Text('${c.title} — ${c.issuer} (${c.year})')).toList(),
              ),
            ],

            // Awards
            if (cvData.awards.isNotEmpty) ...[
              pdfSectionTitle('Awards & Honors'),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: cvData.awards.map((a) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('${a.title} — ${a.year}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  if (a.description.isNotEmpty) pw.Text(a.description),
                  pw.SizedBox(height: 6),
                ])).toList(),
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

            // Research
            if (cvData.researchExperiences.isNotEmpty) ...[
              pdfSectionTitle('Research Experience'),
              pdfBulletList(cvData.researchExperiences),
            ],

            // Teaching
            if (cvData.teachingExperiences.isNotEmpty) ...[
              pdfSectionTitle('Teaching Experience'),
              pdfBulletList(cvData.teachingExperiences),
            ],

            // Professional Development
            if (cvData.professionalDevelopments.isNotEmpty) ...[
              pdfSectionTitle('Professional Development'),
              pdfBulletList(cvData.professionalDevelopments),
            ],

            // Grants
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

    // open native preview (print / save / share)
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("CV Template 1"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Personal Info Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cvData.name,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 6),
                if (cvData.email.isNotEmpty)
                  Text("📧 ${cvData.email}",
                      style: const TextStyle(color: Colors.white)),
                if (cvData.phone.isNotEmpty)
                  Text("📞 ${cvData.phone}",
                      style: const TextStyle(color: Colors.white)),
                if (cvData.address.isNotEmpty)
                  Text("🏠 ${cvData.address}",
                      style: const TextStyle(color: Colors.white)),
                if (cvData.linkedin.isNotEmpty)
                  Text("🔗 ${cvData.linkedin}",
                      style: const TextStyle(color: Colors.white)),
                if (cvData.github.isNotEmpty)
                  Text("💻 ${cvData.github}",
                      style: const TextStyle(color: Colors.white)),
                if (cvData.website.isNotEmpty)
                  Text("🌐 ${cvData.website}",
                      style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Professional Summary
          if (cvData.professionalSummary.isNotEmpty)
            sectionCard(
              title: "Professional Summary",
              icon: Icons.assignment,
              child: Text(cvData.professionalSummary),
            ),

          // Skills
          if (cvData.technicalSkills.isNotEmpty ||
              cvData.softSkills.isNotEmpty ||
              cvData.languages.isNotEmpty ||
              cvData.toolsTechnologies.isNotEmpty)
            sectionCard(
              title: "Skills",
              icon: Icons.build,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cvData.technicalSkills.isNotEmpty)
                    bulletList(cvData.technicalSkills),
                  if (cvData.softSkills.isNotEmpty)
                    bulletList(cvData.softSkills),
                  if (cvData.languages.isNotEmpty)
                    bulletList(cvData.languages),
                  if (cvData.toolsTechnologies.isNotEmpty)
                    bulletList(cvData.toolsTechnologies),
                ],
              ),
            ),

          // Education
          if (cvData.education.isNotEmpty)
            sectionCard(
              title: "Education",
              icon: Icons.school,
              child: Column(
                children: cvData.education.map((edu) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("${edu['degree']} in ${edu['field']}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                    Text("${edu['school']} (${edu['startYear']} - ${edu['endYear']})"),
                  );
                }).toList(),
              ),
            ),

          // Projects
          if (cvData.projects.isNotEmpty)
            sectionCard(
              title: "Projects",
              icon: Icons.code,
              child: Column(
                children: cvData.projects.map((proj) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(proj['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(proj['description'] ?? ''),
                  );
                }).toList(),
              ),
            ),

          // Experience
          if (cvData.experience.isNotEmpty)
            sectionCard(
              title: "Experience",
              icon: Icons.work,
              child: Column(
                children: cvData.experience.map((exp) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("${exp['role']} at ${exp['company']}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Year: ${exp['year']}"),
                  );
                }).toList(),
              ),
            ),

          // Responsibilities
          if (cvData.responsibilities.isNotEmpty)
            sectionCard(
              title: "Responsibilities",
              icon: Icons.task_alt,
              child: bulletList(cvData.responsibilities),
            ),

          // Certifications
          if (cvData.certifications.isNotEmpty)
            sectionCard(
              title: "Certifications",
              icon: Icons.workspace_premium,
              child: Column(
                children: cvData.certifications.map((cert) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("${cert.title} (${cert.year})"),
                    subtitle: Text("Issuer: ${cert.issuer}"),
                  );
                }).toList(),
              ),
            ),

          // Awards
          if (cvData.awards.isNotEmpty)
            sectionCard(
              title: "Awards & Honors",
              icon: Icons.emoji_events,
              child: Column(
                children: cvData.awards.map((award) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("${award.title} (${award.year})"),
                    subtitle: Text(award.description),
                  );
                }).toList(),
              ),
            ),

          // Publications
          if (cvData.publications.isNotEmpty)
            sectionCard(
              title: "Publications",
              icon: Icons.book,
              child: bulletList(cvData.publications),
            ),

          // Conferences / Workshops
          if (cvData.conferences.isNotEmpty)
            sectionCard(
              title: "Conferences / Workshops",
              icon: Icons.mic,
              child: bulletList(cvData.conferences),
            ),

          // References
          if (cvData.references.isNotEmpty)
            sectionCard(
              title: "References",
              icon: Icons.people,
              child: bulletList(cvData.references),
            ),

          // Research Experience
          if (cvData.researchExperiences.isNotEmpty)
            sectionCard(
              title: "Research Experience",
              icon: Icons.science,
              child: bulletList(cvData.researchExperiences),
            ),

          // Professional Development
          if (cvData.professionalDevelopments.isNotEmpty)
            sectionCard(
              title: "Professional Development",
              icon: Icons.school,
              child: bulletList(cvData.professionalDevelopments),
            ),

          // Teaching Experience
          if (cvData.teachingExperiences.isNotEmpty)
            sectionCard(
              title: "Teaching Experience",
              icon: Icons.menu_book,
              child: bulletList(cvData.teachingExperiences),
            ),

          // Grants / Funding
          if (cvData.grants.isNotEmpty)
            sectionCard(
              title: "Grants / Funding",
              icon: Icons.attach_money,
              child: bulletList(cvData.grants),
            ),

          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
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
              onPressed: () => _generatePdf(context),
            ),
          ),
        ),
      ),
    );
  }
}
