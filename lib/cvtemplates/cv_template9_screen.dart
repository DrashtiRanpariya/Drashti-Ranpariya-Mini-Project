import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class CVTemplate9Screen extends StatefulWidget {
  const CVTemplate9Screen({super.key});

  @override
  State<CVTemplate9Screen> createState() => _CVTemplate9ScreenState();
}

class _CVTemplate9ScreenState extends State<CVTemplate9Screen> with TickerProviderStateMixin {
  final cvData = CVData();
  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  late TabController _tabController;
  final List<String> sectionTabs = [
    "👤 Personal",
    "🎓 Education",
    "💼 Experience",
    "💻 Skills",
    "🚀 Projects",
    "📚 Publications",
    "🏅 Certifications",
    "🎯 Awards",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: sectionTabs.length, vsync: this);
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Widget sectionCard({required Widget child, Color? color}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: child,
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
            const Text("• ", style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
            Expanded(child: Text(e)),
          ],
        ),
      )).toList(),
    );
  }

  Widget profileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
            backgroundColor: Colors.grey.shade200,
            child: profileImage == null ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey) : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(cvData.name.isNotEmpty ? cvData.name : "Your Name", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        if (cvData.email.isNotEmpty) Text(cvData.email),
        if (cvData.phone.isNotEmpty) Text(cvData.phone),
      ],
    );
  }

  Widget personalSection() {
    return sectionCard(
      color: Colors.orange.shade50,
      child: profileHeader(),
    );
  }

  Widget educationSection() {
    return sectionCard(
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cvData.education.map((edu) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text("🎓 ${edu['degree']} in ${edu['field']} at ${edu['school']} (${edu['startYear']} - ${edu['endYear']})"),
        )).toList(),
      ),
    );
  }

  Widget experienceSection() {
    return sectionCard(
      color: Colors.green.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cvData.experience.map((exp) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text("💼 ${exp['role']} at ${exp['company']} (${exp['year'] ?? ''})"),
        )).toList(),
      ),
    );
  }

  Widget skillsSection() {
    return sectionCard(
      color: Colors.purple.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cvData.technicalSkills.isNotEmpty) ...[
            const Text("Technical Skills", style: TextStyle(fontWeight: FontWeight.bold)),
            bulletList(cvData.technicalSkills),
          ],
          const SizedBox(height: 8),
          if (cvData.softSkills.isNotEmpty) ...[
            const Text("Soft Skills", style: TextStyle(fontWeight: FontWeight.bold)),
            bulletList(cvData.softSkills),
          ],
          const SizedBox(height: 8),
          if (cvData.languages.isNotEmpty) ...[
            const Text("Languages", style: TextStyle(fontWeight: FontWeight.bold)),
            bulletList(cvData.languages),
          ],
        ],
      ),
    );
  }

  Widget projectsSection() {
    return sectionCard(
      color: Colors.teal.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cvData.projects.map((proj) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text("🚀 ${proj['title']}: ${proj['description']}"),
        )).toList(),
      ),
    );
  }

  Widget publicationsSection() {
    return sectionCard(
      color: Colors.amber.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cvData.publications.isNotEmpty) ...[
            const Text("📚 Publications", style: TextStyle(fontWeight: FontWeight.bold)),
            bulletList(cvData.publications),
          ],
          const SizedBox(height: 8),
          if (cvData.conferences.isNotEmpty) ...[
            const Text("📝 Conferences / Workshops", style: TextStyle(fontWeight: FontWeight.bold)),
            bulletList(cvData.conferences),
          ],
        ],
      ),
    );
  }

  Widget certificationsSection() {
    return sectionCard(
      color: Colors.indigo.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cvData.certifications.map((c) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text("🏅 ${c.title} by ${c.issuer} (${c.year})"),
        )).toList(),
      ),
    );
  }

  Widget awardsSection() {
    return sectionCard(
      color: Colors.pink.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cvData.awards.map((a) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text("🎯 ${a.title} (${a.year}): ${a.description}"),
        )).toList(),
      ),
    );
  }

  // ---------------- PDF generation ----------------
  Future<void> _generatePdf() async {
    final doc = pw.Document();
    final headerColor = PdfColors.deepPurple;
    final accent = PdfColors.cyan700;

    // prepare profile image bytes if provided
    pw.ImageProvider? pdfProfileImage;
    if (profileImage != null && await profileImage!.exists()) {
      final bytes = await File(profileImage!.path).readAsBytes();
      pdfProfileImage = pw.MemoryImage(bytes);
    }

    pw.Widget pdfHeader() {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(color: headerColor),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                if (cvData.name.isNotEmpty)
                  pw.Text(cvData.name, style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Wrap(spacing: 10, runSpacing: 6, children: [
                  if (cvData.email.isNotEmpty) pw.Text('📧 ${cvData.email}', style: pw.TextStyle(color: PdfColors.white)),
                  if (cvData.phone.isNotEmpty) pw.Text('📞 ${cvData.phone}', style: pw.TextStyle(color: PdfColors.white)),
                ]),
              ]),
            ),
            pw.SizedBox(width: 12),
            pw.Container(
              width: 64,
              height: 64,
              decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: PdfColors.white),
              child: pdfProfileImage != null
                  ? pw.ClipOval(child: pw.Image(pdfProfileImage, fit: pw.BoxFit.cover))
                  : pw.Center(child: pw.Text(cvData.name.isNotEmpty ? cvData.name[0].toUpperCase() : 'U', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: headerColor))),
            ),
          ],
        ),
      );
    }

    pw.Widget pdfSectionTitle(String title) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
        child: pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: accent)),
      );
    }

    pw.Widget pdfBulleted(List<String> items) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((s) => pw.Row(children: [pw.Text('• '), pw.Expanded(child: pw.Text(s))])).toList(),
      );
    }

    List<pw.Widget> buildMapList(List<Map<String, String>> maps, String kind) {
      return maps.map((m) {
        if (kind == 'education') {
          final degree = m['degree'] ?? '';
          final field = m['field'] ?? '';
          final school = m['school'] ?? '';
          final start = m['startYear'] ?? '';
          final end = m['endYear'] ?? '';
          return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('$degree in $field', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('$school ($start - $end)', style: pw.TextStyle(color: PdfColors.grey)),
            pw.SizedBox(height: 6),
          ]);
        } else if (kind == 'experience') {
          final role = m['role'] ?? '';
          final company = m['company'] ?? '';
          final year = m['year'] ?? '';
          return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('$role at $company', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Year: $year', style: pw.TextStyle(color: PdfColors.grey)),
            pw.SizedBox(height: 6),
          ]);
        } else if (kind == 'projects') {
          final title = m['title'] ?? '';
          final desc = m['description'] ?? '';
          return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            if (desc.isNotEmpty) pw.Text(desc, style: pw.TextStyle(color: PdfColors.grey)),
            pw.SizedBox(height: 6),
          ]);
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
            pdfHeader(),
            // Personal summary (if present)
            if (cvData.professionalSummary.isNotEmpty) ...[
              pdfSectionTitle('Professional Summary'),
              pw.Text(cvData.professionalSummary),
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
            // Skills
            if (cvData.technicalSkills.isNotEmpty || cvData.softSkills.isNotEmpty) ...[
              pdfSectionTitle('Skills'),
              if (cvData.technicalSkills.isNotEmpty) pdfBulleted(cvData.technicalSkills),
              pw.SizedBox(height: 6),
              if (cvData.softSkills.isNotEmpty) pdfBulleted(cvData.softSkills),
            ],
            // Projects
            if (cvData.projects.isNotEmpty) ...[
              pdfSectionTitle('Projects'),
              ...buildMapList(cvData.projects, 'projects'),
            ],
            // Publications & Conferences
            if (cvData.publications.isNotEmpty) ...[
              pdfSectionTitle('Publications'),
              pdfBulleted(cvData.publications),
            ],
            if (cvData.conferences.isNotEmpty) ...[
              pdfSectionTitle('Conferences / Workshops'),
              pdfBulleted(cvData.conferences),
            ],
            // Certifications
            if (cvData.certifications.isNotEmpty) ...[
              pdfSectionTitle('Certifications'),
              pw.Column(children: cvData.certifications.map((c) => pw.Text('${c.title} — ${c.issuer} (${c.year})')).toList()),
            ],
            // Awards
            if (cvData.awards.isNotEmpty) ...[
              pdfSectionTitle('Awards'),
              pw.Column(children: cvData.awards.map((a) => pw.Text('${a.title} — ${a.year}: ${a.description}')).toList()),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("CV Template 9"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Export as PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.deepPurple,
            tabs: sectionTabs.map((t) => Tab(text: t)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                personalSection(),
                educationSection(),
                experienceSection(),
                skillsSection(),
                projectsSection(),
                publicationsSection(),
                certificationsSection(),
                awardsSection(),
              ],
            ),
          ),
        ],
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
              icon: const Icon(Icons.print),
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
