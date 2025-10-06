// lib/templates/sample_template_screen.dart
//
// Cleaned & improved layout + bullet formatting (UI + PDF).
// Reference resume (uploaded): Jenish Resume Final ( java ).pdf. :contentReference[oaicite:1]{index=1}

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SampleTemplateScreen extends StatefulWidget {
  const SampleTemplateScreen({super.key});

  @override
  State<SampleTemplateScreen> createState() => _SampleTemplateScreenState();
}

class _SampleTemplateScreenState extends State<SampleTemplateScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  // ------------------ Data (from uploaded PDF) ------------------
  final String _name = 'Drashti Ranpariya';
  final String _title = 'B.Tech Student (Computer Science) — Seeking Internship';
  final String _summary =
      'I am Drashti Ranpariya, pursuing B. Tech in CS trying to find an internship to learn, grow and enhance my skills as a fresher/intern.';

  final String _phone = '+91 9712699430';
  final String _email = 'drashtiranpariya20@gmail.com';
  final String _linkedIn =
      'https://www.linkedin.com/in/drashti-ranpariya-673901288/';
  final String _address = 'Rajkot, Gujarat, India';

  final List<Map<String, String>> _education = [
    {
      'title': 'B.Tech Computer Science & Engineering',
      'school': 'Atmiya University, Rajkot',
      'duration': '2022 - 2026',
      'details': 'Current CGPA: 9.75'
    },
    {
      'title': 'HSC (12th) — Science',
      'school': 'Pathak Higher Secondary School',
      'duration': '2020 - 2022',
      'details': 'Completed with 88.64%'
    },
    {
      'title': 'SSC (10th)',
      'school': 'Pathak School',
      'duration': '2019 - 2020',
      'details': 'Completed with 99.92%'
    },
  ];

  final List<String> _skills = [
    'Design (UI / UX - Figma, Canva)',
    'Web Development (HTML, CSS, JavaScript)',
    'Programming Languages (C, C#, Java, Python)',
    'Database Management (SQL)',
  ];

  final List<Map<String, String>> _projects = [
    {
      'title': 'MAHENDI — Website',
      'desc':
      'A static website which gives information about an artist and her work. Users can explore designs by category according to function/occasion.\nLink: https://drashtiranpariya.github.io/website-of-mehandi/'
    },
    {
      'title': 'Mobile App Sign Up Flow (Prototype)',
      'desc':
      'Signup flow design focused on short, personalized and visually appealing UX. Prototype: https://www.figma.com/proto/O5Pu62HhGJVyH2xv9uHIrm/Mobile-App-Sign-up-Flow'
    },
    {
      'title': 'E-Commerce (Travel) App UI/UX',
      'desc':
      'Travel app prototype where users can search places, book and add to wishlist. Includes animations and reusable components.\nPrototype: https://www.figma.com/proto/ErUNTkJ9yuF8FINV9UcNKb/Travel'
    },
    {
      'title': 'Shop Menu UI/UX (Ice cream shop)',
      'desc':
      'Visually appealing, easy-to-read menu design built in Figma that encourages ordering.\nPrototype: https://www.figma.com/proto/ykAoqKSIB1cj33JM8KtKwZ/Restaurant-Menu'
    },
  ];

  final List<Map<String, String>> _internships = [
    {
      'title': 'Social Immersion Internship',
      'org': 'Sadbhavna Vrudhashram, Rajkot',
      'desc':
      'Completed social immersion internship; learned cultural sensitivity, teamwork, collaboration, and insights into non-profit operations.'
    },
    {
      'title': 'UI/UX Design Virtual Internship (1 month)',
      'org': 'Codsoft',
      'desc':
      '4-week virtual internship focused on UI/UX tasks — worked on signup flow, e-commerce travel app prototypes, wireframes and UI deliverables.'
    },
  ];

  final List<String> _certificates = [
    'Certificate of excellence — DMIT Awards 2024',
    'Certificate of excellence — DMIT Awards 2023',
    'Certificate of Intermediate Drawing Grade Examination — State Examination Board, Gujarat (A grade)',
  ];

  final List<String> _interests = ['Drawing', 'Designing', 'Sketching', 'Singing'];

  // unify a single blue color for consistency
  Color get primaryBlue => Colors.blue.shade800;

  // ------------------ lifecycle ------------------
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------ PDF Generation ------------------
  // Replace your existing _generatePdf() with this version
  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final titleColor = PdfColors.blue800;
    final textGrey = PdfColors.grey700;

    pw.Widget sectionTitle(String title) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 10, bottom: 6),
        child: pw.Row(children: [
          pw.Container(width: 4, height: 16, color: titleColor),
          pw.SizedBox(width: 8),
          pw.Text(title,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: titleColor)),
          pw.Expanded(
            child: pw.Container(margin: const pw.EdgeInsets.only(left: 8), height: 1, color: PdfColors.grey300),
          )
        ]),
      );
    }

    pw.Widget pdfBulletList(List<String> items) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((i) => pw.Bullet(text: i)).toList(),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 28, 36, 28),
        build: (pw.Context context) => [
          // Header with icons arranged as tokens
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(
              width: 72,
              height: 72,
              decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(color: titleColor, width: 2)),
              child: pw.Center(
                child: pw.Text(
                  _initials(_name),
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: titleColor),
                ),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(_name, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: titleColor)),
                pw.SizedBox(height: 4),
                pw.Text(_title, style: pw.TextStyle(fontSize: 12, color: textGrey)),
                pw.SizedBox(height: 6),
                pw.Text(_summary, style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
                pw.SizedBox(height: 8),

                // contact tokens row: emoji icons + text, each separated and wrapped when needed
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    pw.Row(children: [
                      pw.Text(_email, style: pw.TextStyle(fontSize: 9, color: textGrey)),
                    ]),
                    pw.Row(children: [
                      pw.Text(_phone, style: pw.TextStyle(fontSize: 9, color: textGrey)),
                    ]),
                    pw.Row(children: [
                      pw.Text(_address, style: pw.TextStyle(fontSize: 9, color: textGrey)),
                    ]),
                    // optionally show linkedIn as its own token
                    pw.Row(children: [
                      pw.Text(_linkedIn, style: pw.TextStyle(fontSize: 10)),
                      // pw.SizedBox(width: 6)
                    ]),
                  ],
                ),
              ]),
            )
          ]),
          pw.SizedBox(height: 12),

          // Education with a small dot before the year/duration
          sectionTitle('Education'),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _education.map((e) {
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                // Title + duration row where duration has a small dot before it
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text('${e['title']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    // right aligned duration with small dot
                    pw.Row(children: [
                      pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(color: titleColor, shape: pw.BoxShape.circle)),
                      pw.SizedBox(width: 6),
                      pw.Text('${e['duration']}', style: pw.TextStyle(color: textGrey)),
                    ]),
                  ],
                ),
                pw.Text('${e['school']}', style: pw.TextStyle(color: textGrey)),
                if (e['details'] != null) pw.Text('${e['details']}', style: pw.TextStyle(color: textGrey)),
                pw.SizedBox(height: 6),
              ]);
            }).toList(),
          ),

          // Skills
          sectionTitle('Skills'),
          pdfBulletList(_skills),

          // Projects
          sectionTitle('Projects'),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _projects.map((p) {
              return pw.Column(children: [
                pw.Bullet(text: p['title'] ?? ''),
                if ((p['desc'] ?? '').isNotEmpty)
                  pw.Padding(padding: const pw.EdgeInsets.only(left: 14, bottom: 6), child: pw.Text(p['desc']!)),
              ]);
            }).toList(),
          ),

          // Internships / Trainings
          sectionTitle('Internships & Trainings'),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _internships.map((i) {
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('${i['title']} — ${i['org']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (i['desc'] != null) pw.Padding(padding: const pw.EdgeInsets.only(left: 8, top: 2, bottom: 6), child: pw.Text(i['desc']!)),
                pw.SizedBox(height: 6),
              ]);
            }).toList(),
          ),

          // Certificates
          sectionTitle('Certificates & Awards'),
          pdfBulletList(_certificates),

          // Interests / Hobbies
          sectionTitle('Interests'),
          pdfBulletList(_interests),

          // Footer links
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 6),
          pw.Text('LinkedIn: $_linkedIn', style: pw.TextStyle(color: textGrey, fontSize: 9)),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // ------------------ UI Helpers ------------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 6),
      child: Row(children: [
        Container(width: 4, height: 18, color: primaryBlue),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primaryBlue)),
        const Expanded(child: SizedBox())
      ]),
    );
  }

  Widget _text(String text, {bool isSub = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6, left: isSub ? 12 : 0),
      child: Text(text, style: TextStyle(fontSize: isSub ? 14 : 15, height: 1.35)),
    );
  }

  // improved UI bullet list: small circular bullet and wrapped text
  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(i, style: const TextStyle(fontSize: 14, height: 1.35))),
            ],
          ),
        );
      }).toList(),
    );
  }

  // project row: title bold + desc under it indented
  Widget _projectItem(Map<String, String> p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            if ((p['desc'] ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(p['desc']!, style: const TextStyle(fontSize: 14, height: 1.35)),
              )
          ]),
        ),
      ]),
    );
  }

  // ------------------ Build ------------------
  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width > 900
        ? 900
        : MediaQuery.of(context).size.width - 24;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sample Template — Drashti Ranpariya',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryBlue,
        centerTitle: true,
        foregroundColor: Colors.white, // ensures icons/text in appBar are white
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Center(
              child: Container(
                width: maxWidth,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryBlue, width: 2),
                  boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.06), offset: const Offset(0, 6), blurRadius: 18)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Header
                  Row(children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryBlue, width: 2)),
                      child: Center(child: Text(_initials(_name), style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryBlue))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(_title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Text(_summary, style: const TextStyle(fontSize: 14, height: 1.4)),
                        const SizedBox(height: 8),
                        // Use Wrap so contact items flow to new line on narrow screens
                        Wrap(spacing: 12, runSpacing: 6, children: [
                          Text('📧 $_email', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          Text('📞 $_phone', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          Text('📍 $_address', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        ]),
                        const SizedBox(height: 6),
                        TextButton.icon(onPressed: () {}, icon: const Icon(Icons.link), label: const Text('LinkedIn / Prototypes')),
                      ]),
                    )
                  ]),
                  const SizedBox(height: 8),

                  // Sections
                  _sectionTitle('Education'),
                  ..._education.map((e) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _text('${e['title']}', isSub: false),
                    _text('${e['school']} • ${e['duration']}', isSub: true),
                    if (e['details'] != null) _text('${e['details']}', isSub: true),
                    const SizedBox(height: 6),
                  ])),

                  _sectionTitle('Skills'),
                  _bulletList(_skills),

                  _sectionTitle('Projects'),
                  ..._projects.map((p) => _projectItem(p)),

                  _sectionTitle('Internships & Trainings'),
                  ..._internships.map((i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _text('${i['title']} — ${i['org']}'),
                    if (i['desc'] != null) _text(i['desc']!, isSub: true),
                    const SizedBox(height: 6),
                  ])),

                  _sectionTitle('Certificates & Awards'),
                  _bulletList(_certificates),

                  _sectionTitle('Interests'),
                  _bulletList(_interests),

                  const SizedBox(height: 10),
                ]),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Download PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white, // ensures text/icon color is white
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
