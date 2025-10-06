import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_data.dart';

class Template3Screen extends StatefulWidget {
  @override
  _Template3ScreenState createState() => _Template3ScreenState();
}

class _Template3ScreenState extends State<Template3Screen>
    with SingleTickerProviderStateMixin {
  final resume = ResumeData();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("✨ Resume Template 3"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT BAND
            Container(
              width: 160,
              color: Colors.teal[200],
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("📇 Contact"),
                  _contactInfo(Icons.person, resume.name),
                  _contactInfo(Icons.work, resume.role),
                  _contactInfo(Icons.email, resume.email),
                  _contactInfo(Icons.phone, resume.phone),
                  _contactInfo(Icons.home, resume.address),
                  _contactInfo(Icons.link, resume.linkedin),
                  _contactInfo(Icons.code, resume.github),
                  _contactInfo(Icons.web, resume.website),
                  SizedBox(height: 20),
                  _sectionTitle("💻 Skills"),
                  _bulletList(resume.technicalSkills, textColor: Colors.white),
                  _bulletList(resume.softSkills, textColor: Colors.white),
                  SizedBox(height: 20),
                  _sectionTitle("🗣 Languages"),
                  _bulletList(resume.languages, textColor: Colors.white),
                  SizedBox(height: 20),
                  _sectionTitle("🎯 Hobbies"),
                  _bulletList(resume.hobbies, textColor: Colors.white),
                ],
              ),
            ),

            SizedBox(width: 20),

            // RIGHT MAIN CONTENT
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 16),
                children: [
                  if (resume.professionalSummary.isNotEmpty)
                    _gradientCard(
                      color: Colors.orangeAccent,
                      emoji: "📝",
                      title: "Professional Summary",
                      child: Text(resume.professionalSummary,
                          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white)),
                    ),

                  _gradientCard(
                    color: Colors.pinkAccent,
                    emoji: "🎓",
                    title: "Education",
                    child: Column(
                      children: resume.education.map((edu) {
                        return ListTile(
                          leading: Icon(Icons.school, color: Colors.white),
                          title: Text("${edu.degree} in ${edu.field}",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Text("${edu.school} (${edu.startYear} - ${edu.endYear})",
                              style: TextStyle(color: Colors.white70)),
                        );
                      }).toList(),
                    ),
                  ),

                  _gradientCard(
                    color: Colors.tealAccent[700]!,
                    emoji: "🚀",
                    title: "Projects",
                    child: Column(
                      children: resume.projects.map((proj) {
                        return ListTile(
                          leading: Icon(Icons.code, color: Colors.white),
                          title: Text(proj.title,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Text(proj.description, style: TextStyle(color: Colors.white70)),
                        );
                      }).toList(),
                    ),
                  ),

                  _gradientCard(
                    color: Colors.indigoAccent,
                    emoji: "💼",
                    title: "Experience",
                    child: Column(
                      children: resume.experience.map((exp) {
                        return ListTile(
                          leading: Icon(Icons.work, color: Colors.white),
                          title: Text("${exp.role} at ${exp.company}",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text("Year: ${exp.year}", style: TextStyle(color: Colors.white70)),
                        );
                      }).toList(),
                    ),
                  ),

                  if (resume.responsibilities.isNotEmpty)
                    _gradientCard(
                      color: Colors.cyanAccent[700]!,
                      emoji: "📌",
                      title: "Key Responsibilities",
                      child: _bulletList(resume.responsibilities, textColor: Colors.white),
                    ),

                  if (resume.certifications.isNotEmpty)
                    _gradientCard(
                      color: Colors.deepPurpleAccent,
                      emoji: "🏅",
                      title: "Certifications",
                      child: Column(
                        children: resume.certifications.map((cert) => ListTile(
                          leading: Icon(Icons.workspace_premium, color: Colors.white),
                          title: Text(cert.title,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text("${cert.issuer} (${cert.year})",
                              style: TextStyle(color: Colors.white70)),
                        )).toList(),
                      ),
                    ),

                  if (resume.awards.isNotEmpty)
                    _gradientCard(
                      color: Colors.amber,
                      emoji: "🏆",
                      title: "Awards",
                      child: Column(
                        children: resume.awards.map((award) => ListTile(
                          leading: Icon(Icons.emoji_events, color: Colors.white),
                          title: Text("${award.title} - ${award.year}",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(award.description, style: TextStyle(color: Colors.white70)),
                        )).toList(),
                      ),
                    ),
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

  // -------------------- Widgets --------------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _contactInfo(IconData icon, String value) {
    if (value.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          SizedBox(width: 6),
          Expanded(child: Text(value, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _bulletList(List<String> items, {Color textColor = Colors.black}) {
    if (items.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• ", style: TextStyle(fontSize: 16, color: textColor)),
            Expanded(child: Text(e, style: TextStyle(fontSize: 15, color: textColor))),
          ],
        ),
      )).toList(),
    );
  }

  Widget _gradientCard(
      {required Color color, required String emoji, required String title, required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$emoji $title",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  // -------------------- PDF Generation --------------------
  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final titleColor = PdfColors.teal800;
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
          pw.Text(resume.name.isNotEmpty ? resume.name : "Your Name",
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold, color: titleColor)),
          if (resume.role.isNotEmpty)
            pw.Text(resume.role, style: pw.TextStyle(color: textGrey)),
          pw.SizedBox(height: 12),

          pdfSectionTitle("Contact"),
          if (resume.email.isNotEmpty) pw.Text("Email: ${resume.email}"),
          if (resume.phone.isNotEmpty) pw.Text("Phone: ${resume.phone}"),
          if (resume.address.isNotEmpty) pw.Text("Address: ${resume.address}"),
          if (resume.linkedin.isNotEmpty) pw.Text("LinkedIn: ${resume.linkedin}"),
          if (resume.github.isNotEmpty) pw.Text("GitHub: ${resume.github}"),
          if (resume.website.isNotEmpty) pw.Text("Website: ${resume.website}"),

          if (resume.professionalSummary.isNotEmpty) ...[
            pdfSectionTitle("Professional Summary"),
            pw.Text(resume.professionalSummary),
          ],

          if (resume.education.isNotEmpty) ...[
            pdfSectionTitle("Education"),
            ...resume.education.map((edu) => pw.Bullet(
                text:
                "${edu.degree} in ${edu.field} — ${edu.school} (${edu.startYear}-${edu.endYear})")),
          ],

          if (resume.technicalSkills.isNotEmpty) ...[
            pdfSectionTitle("Technical Skills"),
            pdfBulletList(resume.technicalSkills),
          ],

          if (resume.softSkills.isNotEmpty) ...[
            pdfSectionTitle("Soft Skills"),
            pdfBulletList(resume.softSkills),
          ],

          if (resume.languages.isNotEmpty) ...[
            pdfSectionTitle("Languages"),
            pdfBulletList(resume.languages),
          ],

          if (resume.toolsTechnologies.isNotEmpty) ...[
            pdfSectionTitle("Tools & Technologies"),
            pdfBulletList(resume.toolsTechnologies),
          ],

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

          if (resume.experience.isNotEmpty) ...[
            pdfSectionTitle("Experience"),
            ...resume.experience.map((e) => pw.Bullet(
                text: "${e.role} at ${e.company} (${e.year})")),
          ],

          if (resume.responsibilities.isNotEmpty) ...[
            pdfSectionTitle("Responsibilities"),
            pdfBulletList(resume.responsibilities),
          ],

          if (resume.certifications.isNotEmpty) ...[
            pdfSectionTitle("Certifications"),
            ...resume.certifications.map((c) => pw.Bullet(
                text: "${c.title} — ${c.issuer} (${c.year})")),
          ],

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
