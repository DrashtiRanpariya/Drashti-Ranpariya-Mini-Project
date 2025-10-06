import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_data.dart';

class Template1Screen extends StatefulWidget {
  @override
  _Template1ScreenState createState() => _Template1ScreenState();
}

class _Template1ScreenState extends State<Template1Screen>
    with SingleTickerProviderStateMixin {
  final resume = ResumeData();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedSection(Widget child) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: child,
      ),
    );
  }

  // -------------------- PDF GENERATION --------------------

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    final titleColor = PdfColors.deepPurple;
    final textGrey = PdfColors.grey700;

    pw.Widget pdfSectionTitle(String title) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 14, bottom: 6),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(width: 4, height: 18, color: titleColor),
            pw.SizedBox(width: 8),
            pw.Text(
              title,
              style: pw.TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                margin: const pw.EdgeInsets.only(left: 12),
                height: 1,
                color: PdfColors.grey300,
              ),
            ),
          ],
        ),
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
        margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 32),
        build: (context) => [
          // Header (Name + contact)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                resume.name.isNotEmpty ? resume.name : 'Your Name',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: titleColor,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                _joinNonEmpty([
                  if (resume.email.isNotEmpty) resume.email,
                  if (resume.phone.isNotEmpty) resume.phone,
                  if (resume.website.isNotEmpty) resume.website,
                ], ' | '),
                style: pw.TextStyle(color: textGrey),
              ),
              if (resume.address.isNotEmpty)
                pw.Text(resume.address, style: pw.TextStyle(color: textGrey)),
              if (resume.linkedin.isNotEmpty || resume.github.isNotEmpty)
                pw.Text(
                  _joinNonEmpty([
                    if (resume.linkedin.isNotEmpty) 'LinkedIn: ${resume.linkedin}',
                    if (resume.github.isNotEmpty) 'GitHub: ${resume.github}',
                  ], '  •  '),
                  style: pw.TextStyle(color: textGrey),
                ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Divider(color: PdfColors.grey300, height: 1),

          // Professional Summary
          if (resume.professionalSummary.isNotEmpty) ...[
            pdfSectionTitle('Professional Summary'),
            pw.Text(resume.professionalSummary),
          ],

          // Education
          if (resume.education.isNotEmpty) ...[
            pdfSectionTitle('Education'),
            ...resume.education.map((edu) => pw.Bullet(
              text:
              '${edu.degree} in ${edu.field} — ${edu.school} (${edu.startYear} - ${edu.endYear})',
            )),
          ],

          // Technical Skills
          if (resume.technicalSkills.isNotEmpty) ...[
            pdfSectionTitle('Technical Skills'),
            pdfBulletList(resume.technicalSkills),
          ],

          // Soft Skills
          if (resume.softSkills.isNotEmpty) ...[
            pdfSectionTitle('Soft Skills'),
            pdfBulletList(resume.softSkills),
          ],

          // Languages
          if (resume.languages.isNotEmpty) ...[
            pdfSectionTitle('Languages'),
            pdfBulletList(resume.languages),
          ],

          // Tools & Technologies
          if (resume.toolsTechnologies.isNotEmpty) ...[
            pdfSectionTitle('Tools & Technologies'),
            pdfBulletList(resume.toolsTechnologies),
          ],

          // Projects
          if (resume.projects.isNotEmpty) ...[
            pdfSectionTitle('Projects'),
            ...resume.projects.map((p) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '• ${p.title}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (p.description.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10, top: 2, bottom: 6),
                    child: pw.Text(p.description),
                  ),
              ],
            )),
          ],

          // Experience
          if (resume.experience.isNotEmpty) ...[
            pdfSectionTitle('Experience'),
            ...resume.experience.map((e) => pw.Bullet(
              text: '${e.role} at ${e.company} (${e.year})',
            )),
          ],

          // Responsibilities / Achievements
          if (resume.responsibilities.isNotEmpty) ...[
            pdfSectionTitle('Responsibilities / Achievements'),
            pdfBulletList(resume.responsibilities),
          ],

          // Certifications
          if (resume.certifications.isNotEmpty) ...[
            pdfSectionTitle('Certifications'),
            ...resume.certifications.map((c) => pw.Bullet(
              text: '${c.title} — ${c.issuer} (${c.year})',
            )),
          ],

          // Awards
          if (resume.awards.isNotEmpty) ...[
            pdfSectionTitle('Awards'),
            ...resume.awards.map((a) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '• ${a.title} (${a.year})',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (a.description.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10, top: 2),
                    child: pw.Text(a.description),
                  ),
              ],
            )),
          ],

          // Hobbies
          if (resume.hobbies.isNotEmpty) ...[
            pdfSectionTitle('Hobbies'),
            pdfBulletList(resume.hobbies),
          ],
        ],
      ),
    );

    // Opens native preview (Share / Print / Save)
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  String _joinNonEmpty(List<String> items, String sep) {
    final filtered = items.where((e) => e.trim().isNotEmpty).toList();
    return filtered.join(sep);
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Template 1'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: _buildAnimatedSection(
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("👤 Personal Information"),
              _buildText("👨 Name: ${resume.name}"),
              _buildText("📧 Email: ${resume.email}"),
              _buildText("📞 Phone: ${resume.phone}"),
              _buildText("🏠 Address: ${resume.address}"),
              _buildText("🔗 LinkedIn: ${resume.linkedin}"),
              _buildText("💻 GitHub: ${resume.github}"),
              _buildText("🌐 Website: ${resume.website}"),

              _buildSectionTitle("🎓 Education"),
              ...resume.education.map((edu) => _buildText(
                  "${edu.degree} in ${edu.field} at ${edu.school} (${edu.startYear} - ${edu.endYear})")),

              _buildSectionTitle("🛠️ Technical Skills"),
              _buildBulletList(resume.technicalSkills),

              _buildSectionTitle("💬 Soft Skills"),
              _buildBulletList(resume.softSkills),

              _buildSectionTitle("🌐 Languages"),
              _buildBulletList(resume.languages),

              _buildSectionTitle("⚙️ Tools & Technologies"),
              _buildBulletList(resume.toolsTechnologies),

              _buildSectionTitle("📁 Projects"),
              ...resume.projects.map((project) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildText("• ${project.title}"),
                  if (project.description.isNotEmpty)
                    _buildText("  ${project.description}", isSubText: true),
                ],
              )),

              _buildSectionTitle("💼 Experience"),
              ...resume.experience.map((exp) => _buildText(
                  "• ${exp.role} at ${exp.company} (${exp.year})")),

              _buildSectionTitle("📝 Professional Summary"),
              if (resume.professionalSummary.isNotEmpty)
                _buildText(resume.professionalSummary),

              _buildSectionTitle("📌 Responsibilities / Achievements"),
              _buildBulletList(resume.responsibilities),

              _buildSectionTitle("📜 Certifications"),
              ...resume.certifications.map((cert) => _buildText(
                  "• ${cert.title} from ${cert.issuer} (${cert.year})")),

              _buildSectionTitle("🏆 Awards"),
              ...resume.awards.map((award) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildText("• ${award.title} (${award.year})"),
                  if (award.description.isNotEmpty)
                    _buildText("  ${award.description}", isSubText: true),
                ],
              )),

              _buildSectionTitle("🎯 Hobbies"),
              _buildBulletList(resume.hobbies),

              const SizedBox(height: 24),
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
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text(
                "Download PDF",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: _generatePdf,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildText(String text, {bool isSubText = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4, left: isSubText ? 16 : 0),
      child: Text(
        text,
        style: TextStyle(fontSize: isSubText ? 14 : 16),
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => _buildText("• $item")).toList(),
    );
  }
}
