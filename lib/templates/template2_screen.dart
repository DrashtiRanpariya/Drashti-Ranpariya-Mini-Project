import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_data.dart';

class Template2Screen extends StatelessWidget {
  final resume = ResumeData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("✨ Resume Template 2"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDEBAR
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade200],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sidebarHeader("👤 Profile"),
                    _contactInfo(Icons.person, resume.name),
                    _contactInfo(Icons.work, resume.role),
                    Divider(color: Colors.white70),
                    _sidebarHeader("📇 Contact"),
                    _contactInfo(Icons.email, resume.email),
                    _contactInfo(Icons.phone, resume.phone),
                    _contactInfo(Icons.home, resume.address),
                    _contactInfo(Icons.link, resume.linkedin),
                    _contactInfo(Icons.code, resume.github),
                    _contactInfo(Icons.web, resume.website),
                    Divider(color: Colors.white70),
                    _sidebarHeader("💻 Skills"),
                    _bulletList(resume.technicalSkills),
                    _sidebarHeader("🤝 Soft Skills"),
                    _bulletList(resume.softSkills),
                    _sidebarHeader("🗣 Languages"),
                    _bulletList(resume.languages),
                    _sidebarHeader("🛠 Tools"),
                    _bulletList(resume.toolsTechnologies),
                    _sidebarHeader("🎯 Hobbies"),
                    _bulletList(resume.hobbies),
                  ],
                ),
              ),
            ),

            SizedBox(width: 20),

            // MAIN CONTENT
            Expanded(
              flex: 5,
              child: ListView(
                children: [
                  if (resume.professionalSummary.isNotEmpty)
                    _mainCard("📝 Professional Summary", Text(resume.professionalSummary)),

                  _mainCard("🎓 Education",
                      Column(children: resume.education.map((edu) => ListTile(
                        leading: Icon(Icons.school, color: Colors.deepPurple),
                        title: Text("${edu.degree} in ${edu.field}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${edu.school} (${edu.startYear} - ${edu.endYear})"),
                      )).toList())),

                  _mainCard("🚀 Projects",
                      Column(children: resume.projects.map((proj) => ListTile(
                        leading: Icon(Icons.code, color: Colors.orange),
                        title: Text(proj.title,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(proj.description),
                      )).toList())),

                  _mainCard("💼 Experience",
                      Column(children: resume.experience.map((exp) => ListTile(
                        leading: Icon(Icons.work, color: Colors.green),
                        title: Text("${exp.role} at ${exp.company}"),
                        subtitle: Text("Year: ${exp.year}"),
                      )).toList())),

                  if (resume.responsibilities.isNotEmpty)
                    _mainCard("📌 Key Responsibilities", _bulletList(resume.responsibilities)),

                  if (resume.certifications.isNotEmpty)
                    _mainCard("🏅 Certifications",
                        Column(children: resume.certifications.map((cert) => ListTile(
                          leading: Icon(Icons.workspace_premium, color: Colors.purple),
                          title: Text(cert.title),
                          subtitle: Text("${cert.issuer} (${cert.year})"),
                        )).toList())),

                  if (resume.awards.isNotEmpty)
                    _mainCard("🏆 Awards",
                        Column(children: resume.awards.map((award) => ListTile(
                          leading: Icon(Icons.emoji_events, color: Colors.amber),
                          title: Text("${award.title} - ${award.year}"),
                          subtitle: Text(award.description),
                        )).toList())),
                ],
              ),
            ),
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

  Widget _sidebarHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Text(title,
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16)),
  );

  Widget _contactInfo(IconData icon, String value) {
    if (value.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          SizedBox(width: 6),
          Expanded(
              child: Text(value,
                  style: TextStyle(fontSize: 14, color: Colors.white))),
        ],
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    if (items.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.5),
        child: Text("• $e",
            style: TextStyle(color: Colors.white, fontSize: 14)),
      ))
          .toList(),
    );
  }

  Widget _mainCard(String title, Widget child) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple)),
            SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  // -------- FULL PDF Generation (like Template1) --------
  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final titleColor = PdfColors.purple800;
    final textGrey = PdfColors.grey700;

    pw.Widget pdfSectionTitle(String title) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 14, bottom: 6),
        child: pw.Text(title,
            style: pw.TextStyle(
                fontSize: 16, fontWeight: pw.FontWeight.bold, color: titleColor)),
      );
    }

    pw.Widget pdfBulletList(List<String> items) {
      if (items.isEmpty) return pw.SizedBox();
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((e) => pw.Bullet(text: e)).toList(),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Text(resume.name.isNotEmpty ? resume.name : "Your Name",
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold, color: titleColor)),
          if (resume.role.isNotEmpty)
            pw.Text(resume.role, style: pw.TextStyle(color: textGrey)),
          pw.SizedBox(height: 12),

          // Contact Info
          pdfSectionTitle("Contact"),
          pw.Text("Email: ${resume.email}"),
          pw.Text("Phone: ${resume.phone}"),
          if (resume.address.isNotEmpty) pw.Text("Address: ${resume.address}"),
          if (resume.linkedin.isNotEmpty) pw.Text("LinkedIn: ${resume.linkedin}"),
          if (resume.github.isNotEmpty) pw.Text("GitHub: ${resume.github}"),
          if (resume.website.isNotEmpty) pw.Text("Website: ${resume.website}"),

          // Professional Summary
          if (resume.professionalSummary.isNotEmpty) ...[
            pdfSectionTitle("Professional Summary"),
            pw.Text(resume.professionalSummary),
          ],

          // Education
          if (resume.education.isNotEmpty) ...[
            pdfSectionTitle("Education"),
            ...resume.education.map((edu) => pw.Bullet(
                text:
                "${edu.degree} in ${edu.field} — ${edu.school} (${edu.startYear}-${edu.endYear})")),
          ],

          // Technical Skills
          if (resume.technicalSkills.isNotEmpty) ...[
            pdfSectionTitle("Technical Skills"),
            pdfBulletList(resume.technicalSkills),
          ],

          // Soft Skills
          if (resume.softSkills.isNotEmpty) ...[
            pdfSectionTitle("Soft Skills"),
            pdfBulletList(resume.softSkills),
          ],

          // Languages
          if (resume.languages.isNotEmpty) ...[
            pdfSectionTitle("Languages"),
            pdfBulletList(resume.languages),
          ],

          // Tools
          if (resume.toolsTechnologies.isNotEmpty) ...[
            pdfSectionTitle("Tools & Technologies"),
            pdfBulletList(resume.toolsTechnologies),
          ],

          // Projects
          if (resume.projects.isNotEmpty) ...[
            pdfSectionTitle("Projects"),
            ...resume.projects.map((p) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("• ${p.title}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (p.description.isNotEmpty)
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10, top: 2),
                      child: pw.Text(p.description)),
              ],
            )),
          ],

          // Experience
          if (resume.experience.isNotEmpty) ...[
            pdfSectionTitle("Experience"),
            ...resume.experience.map((e) => pw.Bullet(
                text: "${e.role} at ${e.company} (${e.year})")),
          ],

          // Responsibilities
          if (resume.responsibilities.isNotEmpty) ...[
            pdfSectionTitle("Responsibilities"),
            pdfBulletList(resume.responsibilities),
          ],

          // Certifications
          if (resume.certifications.isNotEmpty) ...[
            pdfSectionTitle("Certifications"),
            ...resume.certifications.map((c) => pw.Bullet(
                text: "${c.title} — ${c.issuer} (${c.year})")),
          ],

          // Awards
          if (resume.awards.isNotEmpty) ...[
            pdfSectionTitle("Awards"),
            ...resume.awards.map((a) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("• ${a.title} (${a.year})",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (a.description.isNotEmpty)
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10, top: 2),
                      child: pw.Text(a.description)),
              ],
            )),
          ],

          // Hobbies
          if (resume.hobbies.isNotEmpty) ...[
            pdfSectionTitle("Hobbies"),
            pdfBulletList(resume.hobbies),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
