import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class CVTemplate3Screen extends StatefulWidget {
  const CVTemplate3Screen({super.key});

  @override
  State<CVTemplate3Screen> createState() => _CVTemplate3ScreenState();
}

class _CVTemplate3ScreenState extends State<CVTemplate3Screen>
    with SingleTickerProviderStateMixin {
  final cvData = CVData();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
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

  Widget sectionTitle(String emoji, String title, Color color) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget bulletList(List<String> items, {Color textColor = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ", style: TextStyle(fontSize: 16)),
            Expanded(child: Text(e, style: TextStyle(color: textColor))),
          ],
        ),
      ))
          .toList(),
    );
  }

  Widget gradientCard({required Widget child, required List<Color> gradientColors}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }

  Widget timelineEvent(String title, String subtitle, String year, Color dotColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            Container(width: 2, height: 60, color: Colors.grey),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: Colors.white70)),
              if (year.isNotEmpty) Text(year, style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 8),
            ],
          ),
        )
      ],
    );
  }

  Widget sectionCard({
    required String emoji,
    required String title,
    required Widget child,
    required List<Color> colors,
  }) {
    return gradientCard(
      gradientColors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle(emoji, title, Colors.white),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  // ---------------- PDF generation ----------------
  Future<void> _generatePdf() async {
    final doc = pw.Document();
    final titleColor = PdfColors.purple800;
    final grey = PdfColors.grey700;

    pw.Widget pdfSectionTitle(String title) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8, bottom: 6),
        child: pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: titleColor)),
      );
    }

    pw.Widget pdfBulletList(List<String> items) {
      if (items.isEmpty) return pw.SizedBox();
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: items.map((s) => pw.Bullet(text: s)).toList());
    }

    List<pw.Widget> buildMapTimeline(List<Map<String, String>> maps, String type, PdfColor dotColor) {
      return maps.map((m) {
        final leftTitle = (type == 'education') ? '${m['degree'] ?? ''} in ${m['field'] ?? ''}' : (type == 'experience') ? '${m['role'] ?? ''} at ${m['company'] ?? ''}' : (type == 'projects') ? (m['title'] ?? '') : '';
        final subtitle = (type == 'education') ? (m['school'] ?? '') : (type == 'experience') ? (m['details'] ?? '') : (type == 'projects') ? (m['description'] ?? '') : '';
        final year = (type == 'education') ? '${m['startYear'] ?? ''} - ${m['endYear'] ?? ''}' : (type == 'experience') ? (m['year'] ?? '') : '';
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Column(children: [
              pw.Container(width: 10, height: 10, decoration: pw.BoxDecoration(color: dotColor, shape: pw.BoxShape.circle)),
              pw.Container(width: 2, height: 50, color: PdfColors.grey300),
            ]),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(leftTitle, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (subtitle.isNotEmpty) pw.Text(subtitle),
                if (year.isNotEmpty) pw.Text(year, style: pw.TextStyle(color: PdfColors.grey)),
              ]),
            ),
          ]),
        );
      }).toList();
    }

    // Build PDF
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            // Header
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Container(
                width: 64,
                height: 64,
                decoration: const pw.BoxDecoration(shape: pw.BoxShape.circle, color: PdfColors.purple800),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  cvData.name.isNotEmpty ? cvData.name[0].toUpperCase() : 'U',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  if (cvData.name.isNotEmpty) pw.Text(cvData.name, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: titleColor)),
                  pw.SizedBox(height: 6),
                  pw.Wrap(spacing: 8, children: [
                    if (cvData.email.isNotEmpty) pw.Text('Email: ${cvData.email}', style: pw.TextStyle(color: grey)),
                    if (cvData.phone.isNotEmpty) pw.Text('Phone: ${cvData.phone}', style: pw.TextStyle(color: grey)),
                    if (cvData.linkedin.isNotEmpty) pw.Text('LinkedIn: ${cvData.linkedin}', style: pw.TextStyle(color: grey)),
                  ]),
                ]),
              ),
            ]),
            pw.SizedBox(height: 12),

            // Professional summary
            if (cvData.professionalSummary.isNotEmpty) ...[
              pdfSectionTitle('Professional Summary'),
              pw.Text(cvData.professionalSummary),
            ],

            // Skills
            if (cvData.technicalSkills.isNotEmpty || cvData.softSkills.isNotEmpty) ...[
              pdfSectionTitle('Skills'),
              if (cvData.technicalSkills.isNotEmpty) pdfBulletList(cvData.technicalSkills),
              if (cvData.softSkills.isNotEmpty) pdfBulletList(cvData.softSkills),
            ],

            // Education timeline
            if (cvData.education.isNotEmpty) ...[
              pdfSectionTitle('Education'),
              ...buildMapTimeline(cvData.education, 'education', PdfColors.purple),
            ],

            // Experience timeline
            if (cvData.experience.isNotEmpty) ...[
              pdfSectionTitle('Experience'),
              ...buildMapTimeline(cvData.experience, 'experience', PdfColors.teal),
            ],

            // Projects (as short list)
            if (cvData.projects.isNotEmpty) ...[
              pdfSectionTitle('Projects'),
              ...buildMapTimeline(cvData.projects, 'projects', PdfColors.indigo),
            ],

            // Responsibilities
            if (cvData.responsibilities.isNotEmpty) ...[
              pdfSectionTitle('Responsibilities'),
              pdfBulletList(cvData.responsibilities),
            ],

            // Certifications & Awards
            if (cvData.certifications.isNotEmpty) ...[
              pdfSectionTitle('Certifications'),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: cvData.certifications.map((c) => pw.Text('${c.title} — ${c.issuer} (${c.year})')).toList()),
            ],
            if (cvData.awards.isNotEmpty) ...[
              pdfSectionTitle('Awards & Honors'),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: cvData.awards.map((a) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('${a.title} — ${a.year}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (a.description.isNotEmpty) pw.Text(a.description),
                pw.SizedBox(height: 6),
              ])).toList()),
            ],

            // Publications / Conferences / Research etc.
            if (cvData.publications.isNotEmpty) ...[pdfSectionTitle('Publications'), pdfBulletList(cvData.publications)],
            if (cvData.conferences.isNotEmpty) ...[pdfSectionTitle('Conferences / Workshops'), pdfBulletList(cvData.conferences)],
            if (cvData.researchExperiences.isNotEmpty) ...[pdfSectionTitle('Research Experience'), pdfBulletList(cvData.researchExperiences)],
            if (cvData.teachingExperiences.isNotEmpty) ...[pdfSectionTitle('Teaching Experience'), pdfBulletList(cvData.teachingExperiences)],
            if (cvData.professionalDevelopments.isNotEmpty) ...[pdfSectionTitle('Professional Development'), pdfBulletList(cvData.professionalDevelopments)],
            if (cvData.grants.isNotEmpty) ...[pdfSectionTitle('Grants / Funding'), pdfBulletList(cvData.grants)],
            if (cvData.references.isNotEmpty) ...[pdfSectionTitle('References'), pdfBulletList(cvData.references)],
            if (cvData.hobbies.isNotEmpty) ...[pdfSectionTitle('Hobbies / Interests'), pdfBulletList(cvData.hobbies)],
          ];
        },
      ),
    );

    // Show native preview (print / save / share)
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("CV Template 3"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Export as PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header - gradient block
            gradientCard(
              gradientColors: [Colors.deepPurple, Colors.purpleAccent],
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cvData.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        if (cvData.email.isNotEmpty) Text("📧 ${cvData.email}", style: const TextStyle(color: Colors.white)),
                        if (cvData.phone.isNotEmpty) Text("📞 ${cvData.phone}", style: const TextStyle(color: Colors.white)),
                        if (cvData.linkedin.isNotEmpty) Text("🔗 ${cvData.linkedin}", style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        cvData.name.isNotEmpty ? cvData.name[0].toUpperCase() : "U",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Professional Summary
            if (cvData.professionalSummary.isNotEmpty)
              sectionCard(
                emoji: "📝",
                title: "Professional Summary",
                child: Text(cvData.professionalSummary, style: const TextStyle(color: Colors.white)),
                colors: [Colors.pinkAccent, Colors.redAccent],
              ),

            // Skills
            if (cvData.technicalSkills.isNotEmpty || cvData.softSkills.isNotEmpty)
              sectionCard(
                emoji: "💻",
                title: "Skills",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cvData.technicalSkills.isNotEmpty) bulletList(cvData.technicalSkills, textColor: Colors.white),
                    if (cvData.softSkills.isNotEmpty) bulletList(cvData.softSkills, textColor: Colors.white),
                  ],
                ),
                colors: [Colors.orange, Colors.deepOrangeAccent],
              ),

            // Education (timeline)
            if (cvData.education.isNotEmpty)
              sectionCard(
                emoji: "🎓",
                title: "Education",
                child: Column(
                  children: cvData.education.map((edu) => timelineEvent(
                    "${edu['degree']} in ${edu['field']}",
                    edu['school'] ?? "",
                    "${edu['startYear']} - ${edu['endYear']}",
                    Colors.purpleAccent,
                  )).toList(),
                ),
                colors: [Colors.deepPurple, Colors.purpleAccent],
              ),

            // Experience (timeline)
            if (cvData.experience.isNotEmpty)
              sectionCard(
                emoji: "💼",
                title: "Experience",
                child: Column(
                  children: cvData.experience.map((exp) => timelineEvent(
                    "${exp['role']} at ${exp['company']}",
                    exp['details'] ?? "",
                    exp['year'] ?? "",
                    Colors.tealAccent,
                  )).toList(),
                ),
                colors: [Colors.teal, Colors.tealAccent],
              ),

            // Projects
            if (cvData.projects.isNotEmpty)
              sectionCard(
                emoji: "🚀",
                title: "Projects",
                child: Column(
                  children: cvData.projects.map((proj) => Text("${proj['title']}: ${proj['description']}", style: const TextStyle(color: Colors.white))).toList(),
                ),
                colors: [Colors.indigo, Colors.indigoAccent],
              ),

            // Certifications & Awards
            if (cvData.certifications.isNotEmpty)
              sectionCard(
                emoji: "🏅",
                title: "Certifications",
                child: Column(children: cvData.certifications.map((c) => Text("${c.title} (${c.year}) - ${c.issuer}", style: const TextStyle(color: Colors.white))).toList()),
                colors: [Colors.green, Colors.greenAccent],
              ),

            if (cvData.awards.isNotEmpty)
              sectionCard(
                emoji: "🏆",
                title: "Awards & Honors",
                child: Column(children: cvData.awards.map((a) => Text("${a.title} (${a.year}) - ${a.description}", style: const TextStyle(color: Colors.white))).toList()),
                colors: [Colors.amber, Colors.orangeAccent],
              ),

            // Publications / Conferences / Research / Teaching / Grants / References / Hobbies
            if (cvData.publications.isNotEmpty)
              sectionCard(emoji: "📚", title: "Publications", child: bulletList(cvData.publications, textColor: Colors.white), colors: [Colors.purple, Colors.deepPurpleAccent]),
            if (cvData.conferences.isNotEmpty)
              sectionCard(emoji: "🎤", title: "Conferences / Workshops", child: bulletList(cvData.conferences, textColor: Colors.white), colors: [Colors.cyan, Colors.tealAccent]),
            if (cvData.researchExperiences.isNotEmpty)
              sectionCard(emoji: "🔬", title: "Research Experience", child: bulletList(cvData.researchExperiences, textColor: Colors.white), colors: [Colors.orange, Colors.deepOrangeAccent]),
            if (cvData.teachingExperiences.isNotEmpty)
              sectionCard(emoji: "📚", title: "Teaching Experience", child: bulletList(cvData.teachingExperiences, textColor: Colors.white), colors: [Colors.teal, Colors.tealAccent]),
            if (cvData.professionalDevelopments.isNotEmpty)
              sectionCard(emoji: "📖", title: "Professional Development", child: bulletList(cvData.professionalDevelopments, textColor: Colors.white), colors: [Colors.pinkAccent, Colors.redAccent]),
            if (cvData.grants.isNotEmpty)
              sectionCard(emoji: "💰", title: "Grants / Funding", child: bulletList(cvData.grants, textColor: Colors.white), colors: [Colors.green, Colors.greenAccent]),
            if (cvData.references.isNotEmpty)
              sectionCard(emoji: "👥", title: "References", child: bulletList(cvData.references, textColor: Colors.white), colors: [Colors.blueGrey, Colors.grey]),
            if (cvData.hobbies.isNotEmpty)
              sectionCard(emoji: "🎯", title: "Hobbies / Interests", child: bulletList(cvData.hobbies, textColor: Colors.white), colors: [Colors.grey, Colors.blueGrey]),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
