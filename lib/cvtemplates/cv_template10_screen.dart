import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class CVTemplate10Screen extends StatefulWidget {
  const CVTemplate10Screen({super.key});

  @override
  State<CVTemplate10Screen> createState() => _CVTemplate10ScreenState();
}

class _CVTemplate10ScreenState extends State<CVTemplate10Screen> with TickerProviderStateMixin {
  final cvData = CVData();
  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Widget buildProfileAvatar() {
    if (profileImage != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(profileImage!),
      );
    } else if (cvData.name.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.deepPurple,
        child: Text(
          cvData.name[0].toUpperCase(),
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    } else {
      return GestureDetector(
        onTap: pickImage,
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.add_a_photo, size: 36, color: Colors.white),
        ),
      );
    }
  }

  Widget sectionTitle(String title, String emoji, Color start, Color end) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text("$emoji $title", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
            const Text("• ", style: TextStyle(fontSize: 16, color: Colors.black87)),
            Expanded(child: Text(e, style: const TextStyle(fontSize: 15))),
          ],
        ),
      )).toList(),
    );
  }

  Widget timelineSection(List<Map<String, String>> items, String type) {
    return Column(
      children: items.map((item) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 2, height: 20, color: Colors.deepPurple),
              const Icon(Icons.circle, size: 12, color: Colors.deepPurple),
              Container(width: 2, height: 20, color: Colors.deepPurple),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type == "Education"
                          ? "${item['degree']} in ${item['field']}"
                          : "${item['role']} at ${item['company']}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(type == "Education"
                        ? "${item['school']} (${item['startYear']} - ${item['endYear']})"
                        : "Year: ${item['year'] ?? ''}"),
                  ],
                ),
              ),
            ),
          ),
        ],
      )).toList(),
    );
  }

  Widget sectionCard(Widget child, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.7), color.withOpacity(0.4)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  // ---------------- PDF generation ----------------
  Future<void> _generatePdf() async {
    final doc = pw.Document();
    final headerColor = PdfColors.deepPurple;
    final accent = PdfColors.cyan700;

    // load image bytes if present
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
                pw.Wrap(spacing: 8, runSpacing: 6, children: [
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
            if (cvData.professionalSummary.isNotEmpty) ...[
              pdfSectionTitle('Professional Summary'),
              pw.Text(cvData.professionalSummary),
            ],
            if (cvData.education.isNotEmpty) ...[
              pdfSectionTitle('Education'),
              ...buildMapList(cvData.education, 'education'),
            ],
            if (cvData.experience.isNotEmpty) ...[
              pdfSectionTitle('Experience'),
              ...buildMapList(cvData.experience, 'experience'),
            ],
            if (cvData.technicalSkills.isNotEmpty || cvData.softSkills.isNotEmpty) ...[
              pdfSectionTitle('Skills'),
              if (cvData.technicalSkills.isNotEmpty) pdfBulleted(cvData.technicalSkills),
              pw.SizedBox(height: 6),
              if (cvData.softSkills.isNotEmpty) pdfBulleted(cvData.softSkills),
            ],
            if (cvData.projects.isNotEmpty) ...[
              pdfSectionTitle('Projects'),
              ...buildMapList(cvData.projects, 'projects'),
            ],
            if (cvData.certifications.isNotEmpty) ...[
              pdfSectionTitle('Certifications'),
              pw.Column(children: cvData.certifications.map((c) => pw.Text('${c.title} — ${c.issuer} (${c.year})')).toList()),
            ],
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
        title: const Text("CV Template 10"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            tooltip: 'Export as PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(onTap: pickImage, child: buildProfileAvatar()),
            const SizedBox(height: 12),
            if (cvData.professionalSummary.isNotEmpty)
              sectionCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Professional Summary", "📝", Colors.deepPurple, Colors.purpleAccent),
                    const SizedBox(height: 8),
                    Text(cvData.professionalSummary, style: const TextStyle(fontSize: 15)),
                  ],
                ),
                Colors.deepPurpleAccent.shade100,
              ),
            if (cvData.education.isNotEmpty)
              sectionCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Education", "🎓", Colors.blue, Colors.lightBlueAccent),
                    const SizedBox(height: 8),
                    timelineSection(cvData.education, "Education"),
                  ],
                ),
                Colors.blueAccent.shade100,
              ),
            if (cvData.experience.isNotEmpty)
              sectionCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Experience", "💼", Colors.green, Colors.teal),
                    const SizedBox(height: 8),
                    timelineSection(cvData.experience, "Experience"),
                  ],
                ),
                Colors.greenAccent.shade100,
              ),
            if (cvData.technicalSkills.isNotEmpty || cvData.softSkills.isNotEmpty)
              sectionCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Skills", "💻", Colors.orange, Colors.deepOrange),
                    const SizedBox(height: 8),
                    if (cvData.technicalSkills.isNotEmpty) ...[
                      const Text("Technical Skills", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ...cvData.technicalSkills.map((s) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text("• $s"))).toList(),
                      const SizedBox(height: 6),
                    ],
                    if (cvData.softSkills.isNotEmpty) ...[
                      const Text("Soft Skills", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ...cvData.softSkills.map((s) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text("• $s"))).toList(),
                    ],
                  ],
                ),
                Colors.orangeAccent.shade100,
              ),
            if (cvData.projects.isNotEmpty)
              sectionCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Projects", "🚀", Colors.purple, Colors.deepPurpleAccent),
                    const SizedBox(height: 8),
                    Column(
                      children: cvData.projects.map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text("🚀 ${p['title']}: ${p['description']}"),
                      )).toList(),
                    ),
                  ],
                ),
                Colors.purpleAccent.shade100,
              ),
            if (cvData.certifications.isNotEmpty)
              sectionCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Certifications", "🏅", Colors.indigo, Colors.indigoAccent),
                    const SizedBox(height: 8),
                    Column(
                      children: cvData.certifications.map((c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text("🏅 ${c.title} by ${c.issuer} (${c.year})"),
                      )).toList(),
                    ),
                  ],
                ),
                Colors.indigoAccent.shade100,
              ),
            if (cvData.awards.isNotEmpty)
              sectionCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Awards", "🎯", Colors.pink, Colors.pinkAccent),
                    const SizedBox(height: 8),
                    Column(
                      children: cvData.awards.map((a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text("🎯 ${a.title} (${a.year}): ${a.description}"),
                      )).toList(),
                    ),
                  ],
                ),
                Colors.pinkAccent.shade100,
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
