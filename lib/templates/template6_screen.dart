import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_data.dart';

class Template6Screen extends StatefulWidget {
  @override
  _Template6ScreenState createState() => _Template6ScreenState();
}

class _Template6ScreenState extends State<Template6Screen>
    with SingleTickerProviderStateMixin {
  final resume = ResumeData();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
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

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resume Template 6'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: _buildAnimatedSection(
        SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern profile image selection
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : AssetImage('assets/default_profile.png')
                        as ImageProvider,
                      ),
                      // Show overlay + camera icon only if no image uploaded
                      if (_profileImage == null)
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Personal Information
              _buildSectionTitle("👤 Personal Information"),
              _buildText("👨 Name: ${resume.name}"),
              _buildText("📧 Email: ${resume.email}"),
              _buildText("📞 Phone: ${resume.phone}"),
              _buildText("🏠 Address: ${resume.address}"),
              _buildText("🔗 LinkedIn: ${resume.linkedin}"),
              _buildText("💻 GitHub: ${resume.github}"),
              _buildText("🌐 Website: ${resume.website}"),

              // Education
              _buildSectionTitle("🎓 Education"),
              ...resume.education.map((edu) => _buildText(
                  "${edu.degree} in ${edu.field} at ${edu.school} (${edu.startYear} - ${edu.endYear})")),

              // Technical Skills
              _buildSectionTitle("🛠️ Technical Skills"),
              _buildBulletList(resume.technicalSkills),

              // Soft Skills
              _buildSectionTitle("💬 Soft Skills"),
              _buildBulletList(resume.softSkills),

              // Languages
              _buildSectionTitle("🌐 Languages"),
              _buildBulletList(resume.languages),

              // Tools & Technologies
              _buildSectionTitle("⚙️ Tools & Technologies"),
              _buildBulletList(resume.toolsTechnologies),

              // Projects
              _buildSectionTitle("📁 Projects"),
              ...resume.projects.map((project) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildText("• ${project.title}"),
                  if (project.description.isNotEmpty)
                    _buildText("  ${project.description}", isSubText: true),
                ],
              )),

              // Experience
              _buildSectionTitle("💼 Experience"),
              ...resume.experience
                  .map((exp) => _buildText("• ${exp.role} at ${exp.company} (${exp.year})")),

              // Professional Summary
              _buildSectionTitle("📝 Professional Summary"),
              if (resume.professionalSummary.isNotEmpty)
                _buildText(resume.professionalSummary),

              // Responsibilities / Achievements
              _buildSectionTitle("📌 Responsibilities / Achievements"),
              _buildBulletList(resume.responsibilities),

              // Certifications
              _buildSectionTitle("📜 Certifications"),
              ...resume.certifications
                  .map((cert) => _buildText("• ${cert.title} from ${cert.issuer} (${cert.year})")),

              // Awards
              _buildSectionTitle("🏆 Awards"),
              ...resume.awards.map((award) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildText("• ${award.title} (${award.year})"),
                  if (award.description.isNotEmpty)
                    _buildText("  ${award.description}", isSubText: true),
                ],
              )),

              // Hobbies
              _buildSectionTitle("🎯 Hobbies"),
              _buildBulletList(resume.hobbies),
              SizedBox(height: 24),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
    if (items.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => _buildText("• $item")).toList(),
    );
  }

  // ---------------- PDF generation ----------------
  Future<void> _generatePdf() async {
    final doc = pw.Document();
    final titleColor = PdfColors.deepPurple800;
    final textGrey = PdfColors.grey700;

    // helper widgets for PDF
    pw.Widget pdfSectionTitle(String title) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 12, bottom: 6),
        child: pw.Text(title,
            style:
            pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: titleColor)),
      );
    }

    pw.Widget pdfBulletList(List<String> items) {
      if (items.isEmpty) return pw.SizedBox();
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((e) => pw.Bullet(text: e)).toList(),
      );
    }

    // If profile image present, convert to MemoryImage for PDF
    pw.MemoryImage? profileImageForPdf;
    if (_profileImage != null && await _profileImage!.exists()) {
      final bytes = await _profileImage!.readAsBytes();
      profileImageForPdf = pw.MemoryImage(bytes);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header: optionally include image
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            if (profileImageForPdf != null)
              pw.Container(
                width: 80,
                height: 80,
                margin: const pw.EdgeInsets.only(right: 12),
                child: pw.ClipOval(child: pw.Image(profileImageForPdf, fit: pw.BoxFit.cover)),
              ),
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                if (resume.name.isNotEmpty)
                  pw.Text(resume.name,
                      style: pw.TextStyle(
                          fontSize: 22, fontWeight: pw.FontWeight.bold, color: titleColor)),
                if (resume.role.isNotEmpty) pw.Text(resume.role, style: pw.TextStyle(color: textGrey)),
                pw.SizedBox(height: 8),
                if (resume.email.isNotEmpty) pw.Text('Email: ${resume.email}'),
                if (resume.phone.isNotEmpty) pw.Text('Phone: ${resume.phone}'),
                if (resume.address.isNotEmpty) pw.Text('Address: ${resume.address}'),
              ]),
            ),
          ]),
          pw.SizedBox(height: 12),

          // Professional summary
          if (resume.professionalSummary.isNotEmpty) ...[
            pdfSectionTitle('Professional Summary'),
            pw.Text(resume.professionalSummary),
          ],

          // Skills
          if (resume.technicalSkills.isNotEmpty) ...[
            pdfSectionTitle('Technical Skills'),
            pdfBulletList(resume.technicalSkills),
          ],
          if (resume.softSkills.isNotEmpty) ...[
            pdfSectionTitle('Soft Skills'),
            pdfBulletList(resume.softSkills),
          ],

          // Education
          if (resume.education.isNotEmpty) ...[
            pdfSectionTitle('Education'),
            ...resume.education.map((edu) => pw.Bullet(
                text:
                '${edu.degree} in ${edu.field} — ${edu.school} (${edu.startYear}-${edu.endYear})')),
          ],

          // Projects
          if (resume.projects.isNotEmpty) ...[
            pdfSectionTitle('Projects'),
            ...resume.projects.map((p) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ${p.title}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (p.description.isNotEmpty)
                  pw.Padding(padding: const pw.EdgeInsets.only(left: 10, top: 2), child: pw.Text(p.description)),
              ],
            )),
          ],

          // Experience
          if (resume.experience.isNotEmpty) ...[
            pdfSectionTitle('Experience'),
            ...resume.experience.map((e) => pw.Bullet(text: '${e.role} at ${e.company} (${e.year})')),
          ],

          // Responsibilities
          if (resume.responsibilities.isNotEmpty) ...[
            pdfSectionTitle('Responsibilities'),
            pdfBulletList(resume.responsibilities),
          ],

          // Certifications & Awards
          if (resume.certifications.isNotEmpty) ...[
            pdfSectionTitle('Certifications'),
            ...resume.certifications.map((c) => pw.Bullet(text: '${c.title} — ${c.issuer} (${c.year})')),
          ],
          if (resume.awards.isNotEmpty) ...[
            pdfSectionTitle('Awards'),
            ...resume.awards.map((a) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('• ${a.title} (${a.year})', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              if (a.description.isNotEmpty)
                pw.Padding(padding: const pw.EdgeInsets.only(left: 10, top: 2), child: pw.Text(a.description)),
            ])),
          ],

          // Hobbies
          if (resume.hobbies.isNotEmpty) ...[
            pdfSectionTitle('Hobbies'),
            pdfBulletList(resume.hobbies),
          ],
        ],
      ),
    );

    // Open native preview (share / print / save)
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }
}
