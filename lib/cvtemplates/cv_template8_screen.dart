import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class CVTemplate8Screen extends StatefulWidget {
  const CVTemplate8Screen({super.key});

  @override
  State<CVTemplate8Screen> createState() => _CVTemplate8ScreenState();
}

class _CVTemplate8ScreenState extends State<CVTemplate8Screen> with SingleTickerProviderStateMixin {
  final cvData = CVData();
  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animation_controller_forward_safe();
  }

  // safe forward (avoid calling after dispose)
  void _animation_controller_forward_safe() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animationController.forward();
    });
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  Widget progressCircle(String label, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                color: color,
                backgroundColor: color.withOpacity(0.2),
              ),
            ),
            Text("${(value * 100).toInt()}%", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget barItem(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(height: 10, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
              Container(height: 10, width: value, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget sectionCard({required Widget child, Color? color}) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: child,
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
            const Text("• ", style: TextStyle(fontSize: 16, color: Colors.deepOrange)),
            Expanded(child: Text(e)),
          ],
        ),
      )).toList(),
    );
  }

  // ---------------- PDF generation ----------------
  Future<void> _generatePdf() async {
    final doc = pw.Document();
    final bannerStart = PdfColors.orange800;
    final bannerEnd = PdfColors.deepOrange300;
    final grey = PdfColors.grey700;

    // prepare profile image bytes if any
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
        build: (pw.Context context) {
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
                  pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    if (cvData.name.isNotEmpty)
                      pw.Text(cvData.name, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.SizedBox(height: 6),
                    pw.Wrap(spacing: 8, runSpacing: 4, children: [
                      if (cvData.email.isNotEmpty) pw.Text('📧 ${cvData.email}', style: pw.TextStyle(color: PdfColors.white)),
                      if (cvData.phone.isNotEmpty) pw.Text('📞 ${cvData.phone}', style: pw.TextStyle(color: PdfColors.white)),
                    ]),
                  ])),
                  pw.SizedBox(width: 12),
                  pw.Container(
                    width: 64,
                    height: 64,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: PdfColors.white,
                    ),
                    alignment: pw.Alignment.center,
                    child: profilePdfImage != null
                        ? pw.Container(width: 60, height: 60, child: pw.ClipOval(child: pw.Image(profilePdfImage, fit: pw.BoxFit.cover)))
                        : pw.Text(cvData.name.isNotEmpty ? cvData.name[0].toUpperCase() : 'U',
                        style: pw.TextStyle(color: bannerStart, fontSize: 28, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 12),

            // Professional Summary
            if (cvData.professionalSummary.isNotEmpty) ...[
              pdfSectionTitle('Professional Summary'),
              pw.Text(cvData.professionalSummary),
              pw.SizedBox(height: 8),
            ],

            // Skills (render as bullet list + percent text)
            if (cvData.technicalSkills.isNotEmpty) ...[
              pdfSectionTitle('Skills'),
              // convert skill list into bullets (can't do fancy circular graphics easily in pdf here)
              pw.Column(children: cvData.technicalSkills.map((s) => pw.Row(children: [pw.Text('• '), pw.Text(s)])).toList()),
              pw.SizedBox(height: 8),
            ],

            // Experience (rendered)
            if (cvData.experience.isNotEmpty) ...[
              pdfSectionTitle('Experience'),
              ...buildMapList(cvData.experience, 'experience'),
              pw.SizedBox(height: 8),
            ],

            // Education
            if (cvData.education.isNotEmpty) ...[
              pdfSectionTitle('Education'),
              ...buildMapList(cvData.education, 'education'),
              pw.SizedBox(height: 8),
            ],

            // Projects
            if (cvData.projects.isNotEmpty) ...[
              pdfSectionTitle('Projects'),
              ...buildMapList(cvData.projects, 'projects'),
              pw.SizedBox(height: 8),
            ],

            // Publications & Conferences
            if (cvData.publications.isNotEmpty) ...[
              pdfSectionTitle('Publications'),
              pdfBulletList(cvData.publications),
              pw.SizedBox(height: 8),
            ],
            if (cvData.conferences.isNotEmpty) ...[
              pdfSectionTitle('Conferences / Workshops'),
              pdfBulletList(cvData.conferences),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Template 8'),
        backgroundColor: Colors.orange.shade800,
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
                  gradient: LinearGradient(colors: [Colors.orange.shade700, Colors.deepOrangeAccent.shade400]),
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

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Professional Summary
                    if (cvData.professionalSummary.isNotEmpty)
                      sectionCard(
                        color: Colors.orange.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("📝", "Professional Summary", color: Colors.deepOrange),
                            const SizedBox(height: 6),
                            Text(cvData.professionalSummary),
                          ],
                        ),
                      ),

                    // Skills Circle Infographic (UI-only; PDF renders simpler)
                    if (cvData.technicalSkills.isNotEmpty)
                      sectionCard(
                        color: Colors.purple.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("💻", "Skills", color: Colors.purple.shade700),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: cvData.technicalSkills.map((skill) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: progressCircle(skill, 0.8, Colors.purple),
                                )).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Experience bars
                    if (cvData.experience.isNotEmpty)
                      sectionCard(
                        color: Colors.green.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("💼", "Experience", color: Colors.green.shade700),
                            const SizedBox(height: 8),
                            Column(
                              children: cvData.experience.map((exp) => barItem("${exp['role']} at ${exp['company']}", 150, Colors.green)).toList(),
                            ),
                          ],
                        ),
                      ),

                    // Education Timeline
                    if (cvData.education.isNotEmpty)
                      sectionCard(
                        color: Colors.blue.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("🎓", "Education", color: Colors.blue.shade700),
                            const SizedBox(height: 8),
                            Column(
                              children: cvData.education.map((edu) => Text("${edu['degree']} in ${edu['field']} at ${edu['school']} (${edu['startYear']} - ${edu['endYear']})")).toList(),
                            ),
                          ],
                        ),
                      ),

                    // Projects
                    if (cvData.projects.isNotEmpty)
                      sectionCard(
                        color: Colors.teal.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("🚀", "Projects", color: Colors.teal.shade700),
                            const SizedBox(height: 6),
                            Column(
                              children: cvData.projects.map((proj) => Text("${proj['title']}: ${proj['description']}")).toList(),
                            ),
                          ],
                        ),
                      ),

                    // Publications / Conferences
                    if (cvData.publications.isNotEmpty)
                      sectionCard(
                        color: Colors.amber.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("📚", "Publications", color: Colors.amber.shade700),
                            const SizedBox(height: 6),
                            bulletList(cvData.publications),
                          ],
                        ),
                      ),

                    if (cvData.conferences.isNotEmpty)
                      sectionCard(
                        color: Colors.amber.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("📝", "Conferences / Workshops", color: Colors.amber.shade700),
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade800,
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
