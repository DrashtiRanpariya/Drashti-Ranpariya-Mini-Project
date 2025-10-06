import 'package:flutter/material.dart';
import '../cvtemplates/cv_template1_screen.dart';
import '../cvtemplates/cv_template2_screen.dart';
import '../cvtemplates/cv_template3_screen.dart';
import '../cvtemplates/cv_template4_screen.dart';
import '../cvtemplates/cv_template5_screen.dart';
import '../cvtemplates/cv_template6_screen.dart';
import '../cvtemplates/cv_template7_screen.dart';
import '../cvtemplates/cv_template8_screen.dart';
import '../cvtemplates/cv_template9_screen.dart';
import '../cvtemplates/cv_template10_screen.dart';
import '../cvtemplates/sample_cv_template_screen.dart'; // <-- sample template import

class CvTemplateSelectionScreen extends StatelessWidget {
  const CvTemplateSelectionScreen({super.key});

  void _navigateToTemplate(BuildContext context, int templateNumber) {
    Widget templateScreen;
    switch (templateNumber) {
      case 1:
        templateScreen = CVTemplate1Screen();
        break;
      case 2:
        templateScreen = CVTemplate2Screen();
        break;
      case 3:
        templateScreen = CVTemplate3Screen();
        break;
      case 4:
        templateScreen = CVTemplate4Screen();
        break;
      case 5:
        templateScreen = CVTemplate5Screen();
        break;
      case 6:
        templateScreen = CVTemplate6Screen();
        break;
      case 7:
        templateScreen = CVTemplate7Screen();
        break;
      case 8:
        templateScreen = CVTemplate8Screen();
        break;
      case 9:
        templateScreen = CVTemplate9Screen();
        break;
      case 10:
        templateScreen = CVTemplate10Screen();
        break;
      default:
        templateScreen = CVTemplate1Screen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => templateScreen),
    );
  }

  void _navigateToSampleTemplate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SampleCvTemplateScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = List.generate(10, (index) {
      return {
        'title': 'CV Template ${index + 1}',
        'number': index + 1,
      };
    });

    // fixed card height used for all buttons/cards
    final double cardHeight = 88;

    Widget _buildCard({required Widget child, required VoidCallback onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: cardHeight,
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
          child: Center(child: child),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select CV Template',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sample (Standard) Template button at top
            _buildCard(
              onTap: () => _navigateToSampleTemplate(context),
              child: const Text(
                'Sample (Standard) Template',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Templates list
            Expanded(
              child: ListView.separated(
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final template = templates[index];

                  return _buildCard(
                    onTap: () => _navigateToTemplate(context, template['number'] as int),
                    child: Text(
                      template['title'] as String,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
