// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../models/resume_data.dart';
//
// class PreviewScreen extends StatelessWidget {
//   final ResumeData data = ResumeData();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF9FAFB),
//       appBar: AppBar(
//         title: Text('📄 Resume Preview'),
//         backgroundColor: Colors.teal.shade700,
//         foregroundColor: Colors.white,
//         elevation: 4,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//             _buildSectionTitle('👤 Personal Info'),
//             _buildIconText(Icons.person, 'Name', data.name),
//             _buildIconText(Icons.email, 'Email', data.email),
//             _buildIconText(Icons.phone, 'Phone', data.phone),
//             _buildIconText(Icons.location_on, 'Address', data.address),
//             _buildIconText(FontAwesomeIcons.linkedin, 'LinkedIn', data.linkedin),
//             _buildIconText(FontAwesomeIcons.github, 'GitHub', data.github),
//             _buildIconText(Icons.web, 'Website', data.website),
//
//             _buildSectionTitle('🎓 Education'),
//             ...data.education.map((edu) => _buildBulletItem(
//               '${edu['degree'] ?? ''} • ${edu['institution'] ?? ''} (${edu['year'] ?? ''})',
//             )),
//
//             _buildSectionTitle('💡 Skills'),
//             _buildListChips('Technical Skills', data.technicalSkills),
//             _buildListChips('Soft Skills', data.softSkills),
//             _buildListChips('Languages', data.languages),
//             _buildListChips('Tools & Tech', data.toolsTechnologies),
//
//             _buildSectionTitle('💼 Projects'),
//             ...data.projects.map((proj) => _buildBulletItem(
//               '${proj['title']}: ${proj['description']}',
//             )),
//
//             _buildSectionTitle('🏢 Experience'),
//             ...data.experience.map((exp) => _buildBulletItem(
//               '${exp['role']} at ${exp['company']} (${exp['year']})',
//             )),
//
//             if (data.professionalSummary.isNotEmpty) ...[
//               _buildSectionTitle('🧭 Career Objective'),
//               _buildParagraph(data.professionalSummary),
//             ],
//
//             if (data.responsibilities.isNotEmpty) ...[
//               _buildSectionTitle('📌 Responsibilities & Achievements'),
//               ...data.responsibilities.map((resp) => _buildBulletItem(resp)),
//             ],
//
//             if (data.certifications.isNotEmpty) ...[
//               _buildSectionTitle('📚 Certifications'),
//               ...data.certifications.map((cert) => _buildBulletItem(
//                 '${cert.title} - ${cert.issuer} (${cert.year})',
//               )),
//             ],
//
//             if (data.awards.isNotEmpty) ...[
//               _buildSectionTitle('🏆 Honors & Awards'),
//               ...data.awards.map((award) => _buildBulletItem(
//                 '${award.title}: ${award.description} (${award.year})',
//               )),
//             ],
//
//             if (data.hobbies.isNotEmpty) ...[
//               _buildSectionTitle('🎯 Interests / Hobbies'),
//               _buildParagraph(data.hobbies.join(', ')),
//             ],
//
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // 🔹 Section title with emoji
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 24, bottom: 10),
//       child: AnimatedOpacity(
//         opacity: 1.0,
//         duration: Duration(milliseconds: 500),
//         child: Text(
//           title,
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.teal.shade700,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // 🔹 Icon + Text (for personal info)
//   Widget _buildIconText(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey.shade700),
//           SizedBox(width: 8),
//           Text(
//             '$label: ',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           Expanded(
//             child: Text(value, style: TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 🔹 Paragraph style
//   Widget _buildParagraph(String content) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Text(
//         content,
//         style: TextStyle(fontSize: 16, height: 1.5),
//       ),
//     );
//   }
//
//   // 🔹 Bullet point item
//   Widget _buildBulletItem(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("• ", style: TextStyle(fontSize: 18)),
//           Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
//         ],
//       ),
//     );
//   }
//
//   // 🔹 List with chips
//   Widget _buildListChips(String title, List<String> items) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('$title:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           Wrap(
//             spacing: 8,
//             children: items.map((item) => Chip(label: Text(item))).toList(),
//           )
//         ],
//       ),
//     );
//   }
// }
