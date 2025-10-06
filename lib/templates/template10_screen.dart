import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_data.dart';

class Template10Screen extends StatefulWidget {
  @override
  _Template10ScreenState createState() => _Template10ScreenState();
}

class _Template10ScreenState extends State<Template10Screen> with SingleTickerProviderStateMixin {
  final resume = ResumeData();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.deepPurpleAccent,
        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
        child: _profileImage == null
            ? Text(
          resume.name.isNotEmpty ? resume.name[0].toUpperCase() : '?',
          style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
        )
            : null,
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Color? startColor,
    Color? endColor,
    IconData? icon,
  }) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor ?? Colors.deepPurple, endColor ?? Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) Icon(icon, color: Colors.white),
                  if (icon != null) SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    if (items.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ", style: TextStyle(color: Colors.white, fontSize: 16)),
              Expanded(
                child: Text(item, style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("🌟 Modern Resume"),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 6,
        shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // PROFILE IMAGE
          Center(child: _buildProfileImage()),
          SizedBox(height: 16),

          // HEADER: Name & Role
          if (resume.name.isNotEmpty || resume.role.isNotEmpty)
            _sectionCard(
              title: "👤 ${resume.name}",
              icon: Icons.person,
              startColor: Colors.indigoAccent,
              endColor: Colors.blueAccent,
              child: resume.role.isNotEmpty
                  ? Text(resume.role, style: TextStyle(color: Colors.white, fontSize: 16))
                  : SizedBox.shrink(),
            ),

          // CONTACT INFO
          _sectionCard(
            title: "📇 Contact Info",
            icon: Icons.contact_mail,
            startColor: Colors.teal,
            endColor: Colors.tealAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resume.email.isNotEmpty) Text("✉️ Email: ${resume.email}", style: TextStyle(color: Colors.white)),
                if (resume.phone.isNotEmpty) Text("📞 Phone: ${resume.phone}", style: TextStyle(color: Colors.white)),
                if (resume.linkedin.isNotEmpty) Text("🔗 LinkedIn: ${resume.linkedin}", style: TextStyle(color: Colors.white)),
                if (resume.github.isNotEmpty) Text("💻 GitHub: ${resume.github}", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),

          // PROFESSIONAL SUMMARY
          if (resume.professionalSummary.isNotEmpty)
            _sectionCard(
              title: "📝 Professional Summary",
              icon: Icons.description,
              startColor: Colors.deepPurple,
              endColor: Colors.purpleAccent,
              child: Text(resume.professionalSummary, style: TextStyle(color: Colors.white, height: 1.5)),
            ),

          // SKILLS
          if (resume.technicalSkills.isNotEmpty || resume.softSkills.isNotEmpty)
            _sectionCard(
              title: "💡 Skills",
              icon: Icons.build_circle,
              startColor: Colors.orangeAccent,
              endColor: Colors.deepOrangeAccent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (resume.technicalSkills.isNotEmpty) _bulletList(resume.technicalSkills),
                  if (resume.softSkills.isNotEmpty) _bulletList(resume.softSkills),
                ],
              ),
            ),

          // EDUCATION
          if (resume.education.isNotEmpty)
            _sectionCard(
              title: "🎓 Education",
              icon: Icons.school,
              startColor: Colors.pinkAccent,
              endColor: Colors.redAccent,
              child: Column(
                children: resume.education.map((edu) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.school, color: Colors.white),
                      title: Text("${edu.degree} in ${edu.field}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text("${edu.school} (${edu.startYear} - ${edu.endYear})", style: TextStyle(color: Colors.white70)),
                    ),
                  );
                }).toList(),
              ),
            ),

          // EXPERIENCE
          if (resume.experience.isNotEmpty)
            _sectionCard(
              title: "💼 Experience",
              icon: Icons.work,
              startColor: Colors.greenAccent,
              endColor: Colors.teal,
              child: Column(
                children: resume.experience.map((exp) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.work, color: Colors.white),
                      title: Text("${exp.role} at ${exp.company}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text("Year: ${exp.year}", style: TextStyle(color: Colors.white70)),
                    ),
                  );
                }).toList(),
              ),
            ),

          // PROJECTS
          if (resume.projects.isNotEmpty)
            _sectionCard(
              title: "🚀 Projects",
              icon: Icons.code,
              startColor: Colors.indigoAccent,
              endColor: Colors.blueAccent,
              child: Column(
                children: resume.projects.map((proj) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.code, color: Colors.white),
                      title: Text(proj.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(proj.description, style: TextStyle(color: Colors.white70)),
                    ),
                  );
                }).toList(),
              ),
            ),

          // CERTIFICATIONS & AWARDS
          if (resume.certifications.isNotEmpty || resume.awards.isNotEmpty)
            _sectionCard(
              title: "🏅 Achievements",
              icon: Icons.emoji_events,
              startColor: Colors.amber,
              endColor: Colors.orangeAccent,
              child: Column(
                children: [
                  if (resume.certifications.isNotEmpty)
                    ...resume.certifications.map((cert) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.workspace_premium, color: Colors.white),
                      title: Text(cert.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text("${cert.issuer} (${cert.year})", style: TextStyle(color: Colors.white70)),
                    )),
                  if (resume.awards.isNotEmpty)
                    ...resume.awards.map((award) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.emoji_events, color: Colors.white),
                      title: Text("${award.title} - ${award.year}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(award.description, style: TextStyle(color: Colors.white70)),
                    )),
                ],
              ),
            ),

          SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
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

  // ---------------- PDF generation ----------------
  Future<void> _generatePdf() async {
    final doc = pw.Document();
    final titleColor = PdfColors.deepPurple800;
    final textGrey = PdfColors.grey700;

    pw.Widget pdfSectionTitle(String title) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 12, bottom: 6),
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

    // prepare profile image for PDF if exists
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
          // Header row with optional image
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

    // open native preview (print/share/save)
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }
}
