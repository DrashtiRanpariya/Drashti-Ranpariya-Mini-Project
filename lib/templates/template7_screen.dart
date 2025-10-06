import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_data.dart';

class Template7Screen extends StatefulWidget {
  @override
  _Template7ScreenState createState() => _Template7ScreenState();
}

class _Template7ScreenState extends State<Template7Screen> {
  final resume = ResumeData();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("🎨 Resume Template 7"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT COLUMN (Sidebar)
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PROFILE IMAGE SECTION
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : AssetImage('assets/default_profile.png')
                              as ImageProvider,
                            ),
                            if (_profileImage == null)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    _sectionTitle("📇 Contact"),
                    _contactInfo(Icons.person, resume.name),
                    _contactInfo(Icons.email, resume.email),
                    _contactInfo(Icons.phone, resume.phone),
                    _contactInfo(Icons.home, resume.address),
                    _contactInfo(Icons.link, resume.linkedin),
                    _contactInfo(Icons.code, resume.github),
                    _contactInfo(Icons.web, resume.website),
                    SizedBox(height: 20),

                    _sectionTitle("💻 Skills"),
                    _bulletList(resume.technicalSkills),
                    _bulletList(resume.softSkills),
                    SizedBox(height: 20),

                    _sectionTitle("🗣 Languages"),
                    _bulletList(resume.languages),
                    SizedBox(height: 20),

                    _sectionTitle("🛠 Tools & Technologies"),
                    _bulletList(resume.toolsTechnologies),
                    SizedBox(height: 20),

                    _sectionTitle("🎯 Hobbies"),
                    _bulletList(resume.hobbies),
                  ],
                ),
              ),
            ),

            SizedBox(width: 20),

            // RIGHT COLUMN (Main Content)
            Expanded(
              flex: 4,
              child: ListView(
                children: [
                  if (resume.professionalSummary.isNotEmpty) ...[
                    _animatedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("📝 Professional Summary"),
                          Text(
                            resume.professionalSummary,
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],

                  _animatedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("🎓 Education"),
                        ...resume.education.map((edu) => ListTile(
                          leading:
                          Icon(Icons.school, color: Colors.deepPurple),
                          title: Text("${edu.degree} in ${edu.field}",
                              style:
                              TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              "${edu.school} (${edu.startYear} - ${edu.endYear})"),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  _animatedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("🚀 Projects"),
                        ...resume.projects.map((proj) => ListTile(
                          leading: Icon(Icons.code, color: Colors.orange),
                          title: Text(proj.title,
                              style:
                              TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(proj.description),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  _animatedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("💼 Experience"),
                        ...resume.experience.map((exp) => ListTile(
                          leading: Icon(Icons.work, color: Colors.green),
                          title: Text("${exp.role} at ${exp.company}"),
                          subtitle: Text("Year: ${exp.year}"),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  if (resume.responsibilities.isNotEmpty)
                    _animatedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("📌 Key Responsibilities"),
                          _bulletList(resume.responsibilities),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),

                  if (resume.certifications.isNotEmpty)
                    _animatedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("🏅 Certifications"),
                          ...resume.certifications.map((cert) => ListTile(
                            leading: Icon(Icons.workspace_premium,
                                color: Colors.purple),
                            title: Text(cert.title),
                            subtitle:
                            Text("${cert.issuer} (${cert.year})"),
                          )),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),

                  if (resume.awards.isNotEmpty)
                    _animatedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("🏆 Awards"),
                          ...resume.awards.map((award) => ListTile(
                            leading:
                            Icon(Icons.emoji_events, color: Colors.amber),
                            title: Text("${award.title} - ${award.year}"),
                            subtitle: Text(award.description),
                          )),
                        ],
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _contactInfo(IconData icon, String value) {
    if (value.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    if (items.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ", style: TextStyle(fontSize: 16)),
              Expanded(child: Text(e, style: TextStyle(fontSize: 15))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _animatedCard({required Widget child}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
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
