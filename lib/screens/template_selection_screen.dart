import 'package:flutter/material.dart';
import '../templates/template1_screen.dart';
import '../templates/template2_screen.dart';
import '../templates/template3_screen.dart';
import '../templates/template4_screen.dart';
import '../templates/template5_screen.dart';
import '../templates/template6_screen.dart';
import '../templates/template7_screen.dart';
import '../templates/template8_screen.dart';
import '../templates/template9_screen.dart';
import '../templates/template10_screen.dart';
import '../templates/sample_template_screen.dart'; // <-- Import your sample template

class TemplateSelectionScreen extends StatelessWidget {
  const TemplateSelectionScreen({super.key});

  void _navigateToTemplate(BuildContext context, int templateNumber) {
    Widget templateScreen;
    switch (templateNumber) {
      case 0:
        templateScreen = const SampleTemplateScreen(); // <-- Case for sample template
        break;
      case 1:
        templateScreen = Template1Screen();
        break;
      case 2:
        templateScreen = Template2Screen();
        break;
      case 3:
        templateScreen = Template3Screen();
        break;
      case 4:
        templateScreen = Template4Screen();
        break;
      case 5:
        templateScreen = Template5Screen();
        break;
      case 6:
        templateScreen = Template6Screen();
        break;
      case 7:
        templateScreen = Template7Screen();
        break;
      case 8:
        templateScreen = Template8Screen();
        break;
      case 9:
        templateScreen = Template9Screen();
        break;
      case 10:
        templateScreen = Template10Screen();
        break;
      default:
        templateScreen = Template1Screen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => templateScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = [
      {'title': 'Sample (Standard) Template', 'number': 0}, // <-- Added at top
      ...List.generate(10, (index) {
        return {
          'title': 'Template ${index + 1}',
          'number': index + 1,
        };
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Resume Template',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: templates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final template = templates[index];
            return GestureDetector(
              onTap: () => _navigateToTemplate(context, template['number'] as int),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      offset: const Offset(0, 6),
                      blurRadius: 8,
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Center(
                  child: Text(
                    template['title'] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
