import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class CVTemplate7Screen extends StatefulWidget {
  const CVTemplate7Screen({super.key});

  @override
  State<CVTemplate7Screen> createState() => _CVTemplate7ScreenState();
}

class _CVTemplate7ScreenState extends State<CVTemplate7Screen> with SingleTickerProviderStateMixin {
  final cvData = CVData();
  File? profileImage;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Widget sectionTitle(String emoji, String title, {Color? color}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 22, color: color ?? Colors.black87)),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color ?? Colors.black87)),
        ],
      ),
    );
  }

  Widget timelineItem(String title, String subtitle, String year, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            Container(width: 2, height: 60, color: color),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black87)),
              const SizedBox(height: 2),
              Text(year, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            ],
          ),
        ),
      ],
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
            const Text("• ", style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
            Expanded(child: Text(e)),
          ],
        ),
      )).toList(),
    );
  }

  Widget sectionCard({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }

  // ---------------- PDF generation ----------------
  Future<void> _generatePdf() async {
    final doc = pw.Document();
    final bannerStart = PdfColors.deepPurple;
    final bannerEnd = PdfColors.purple300;
    final grey = PdfColors.grey700;

    // prepare profile image for PDF if present
    pw.ImageProvider? profilePdfImage;
    if (profileImage != null && await profileImage!.exists()) {
      final bytes = await File(profileImage!.path).readAsBytes();
      profilePdfImage = pw.MemoryImage(bytes);
    }

    pw.Widget pdfSectionTitle(String title) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
        child: pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
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
          return pw.Container(margin: const pw.EdgeInsets.only(bottom: 6), child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('$role at $company', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Year: $year', style: pw.TextStyle(color: grey)),
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
                children: [
                  pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    if (cvData.name.isNotEmpty)
                      pw.Text(cvData.name, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.SizedBox(height: 6),
                    pw.Wrap(spacing: 8, runSpacing: 4, children: [
                      if (cvData.email.isNotEmpty) pw.Text('📧 ${cvData.email}', style: pw.TextStyle(color: PdfColors.white)),
                      if (cvData.phone.isNotEmpty) pw.Text('📞 ${cvData.phone}', style: pw.TextStyle(color: PdfColors.white)),
                    ]),
                  ])),
                  pw.Container(
                    width: 64,
                    height: 64,
                    decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: PdfColors.white),
                    alignment: pw.Alignment.center,
                    child: profilePdfImage != null
                        ? pw.ClipOval(child: pw.Image(profilePdfImage, width: 60, height: 60, fit: pw.BoxFit.cover))
                        : pw.Text(cvData.name.isNotEmpty ? cvData.name[0].toUpperCase() : 'U', style: pw.TextStyle(color: bannerStart, fontSize: 28, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 12),

            // Single-column flow but keeping sections; timeline entries rendered sequentially
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

            if (cvData.technicalSkills.isNotEmpty) ...[
              pdfSectionTitle('Technical Skills'),
              pdfBulletList(cvData.technicalSkills),
              pw.SizedBox(height: 8),
            ],

            if (cvData.softSkills.isNotEmpty) ...[
              pdfSectionTitle('Soft Skills'),
              pdfBulletList(cvData.softSkills),
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

            if (cvData.references.isNotEmpty) ...[
              pdfSectionTitle('References'),
              pdfBulletList(cvData.references),
            ],
          ];
        },
      ),
    );

    // Open native preview (print / save / share)
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Template 7'),
        backgroundColor: Colors.deepPurple.shade700,
        actions: [
          IconButton(
            tooltip: 'Export as PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with profile image
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.deepPurple.shade700, Colors.purpleAccent.shade400]),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white70,
                        backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                        child: profileImage == null ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(cvData.name.isNotEmpty ? cvData.name : "Your Name", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (cvData.email.isNotEmpty) Text(cvData.email, style: const TextStyle(color: Colors.white70)),
                    if (cvData.phone.isNotEmpty) Text(cvData.phone, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),

              // Main CV content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cvData.professionalSummary.isNotEmpty)
                      sectionCard(
                        color: Colors.purple.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("📝", "Professional Summary", color: Colors.deepPurple),
                            const SizedBox(height: 6),
                            Text(cvData.professionalSummary),
                          ],
                        ),
                      ),

                    if (cvData.education.isNotEmpty)
                      sectionCard(
                        color: Colors.blue.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("🎓", "Education", color: Colors.blue.shade700),
                            const SizedBox(height: 8),
                            Column(
                              children: cvData.education.map((edu) => timelineItem("${edu['degree']} in ${edu['field']}", edu['school'] ?? '', "${edu['startYear']} - ${edu['endYear']}", Colors.blue)).toList(),
                            ),
                          ],
                        ),
                      ),

                    if (cvData.experience.isNotEmpty)
                      sectionCard(
                        color: Colors.green.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("💼", "Experience", color: Colors.green.shade700),
                            const SizedBox(height: 8),
                            Column(
                              children: cvData.experience.map((exp) => timelineItem("${exp['role']} at ${exp['company']}", "", exp['year'] ?? '', Colors.green)).toList(),
                            ),
                          ],
                        ),
                      ),

                    if (cvData.projects.isNotEmpty)
                      sectionCard(
                        color: Colors.orange.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("🚀", "Projects", color: Colors.orange.shade700),
                            const SizedBox(height: 6),
                            Column(
                              children: cvData.projects.map((proj) => Text("${proj['title']}: ${proj['description']}")).toList(),
                            ),
                          ],
                        ),
                      ),

                    if (cvData.technicalSkills.isNotEmpty || cvData.softSkills.isNotEmpty || cvData.toolsTechnologies.isNotEmpty)
                      sectionCard(
                        color: Colors.pink.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("💻", "Skills & Tools", color: Colors.pink.shade700),
                            const SizedBox(height: 6),
                            if (cvData.technicalSkills.isNotEmpty) bulletList(cvData.technicalSkills),
                            if (cvData.softSkills.isNotEmpty) bulletList(cvData.softSkills),
                            if (cvData.toolsTechnologies.isNotEmpty) bulletList(cvData.toolsTechnologies),
                          ],
                        ),
                      ),

                    if (cvData.publications.isNotEmpty)
                      sectionCard(
                        color: Colors.teal.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("📚", "Publications", color: Colors.teal.shade700),
                            const SizedBox(height: 6),
                            bulletList(cvData.publications),
                          ],
                        ),
                      ),

                    if (cvData.conferences.isNotEmpty)
                      sectionCard(
                        color: Colors.teal.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("📝", "Conferences / Workshops", color: Colors.teal.shade700),
                            const SizedBox(height: 6),
                            bulletList(cvData.conferences),
                          ],
                        ),
                      ),

                    if (cvData.references.isNotEmpty)
                      sectionCard(
                        color: Colors.grey.shade200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("📇", "References", color: Colors.grey.shade800),
                            const SizedBox(height: 6),
                            bulletList(cvData.references),
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
                backgroundColor: Colors.deepPurple.shade700,
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
