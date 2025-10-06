import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cv_data.dart';

class CVPersonalInfoScreen extends StatefulWidget {
  const CVPersonalInfoScreen({super.key});

  @override
  State<CVPersonalInfoScreen> createState() => _CVPersonalInfoScreenState();
}

class _CVPersonalInfoScreenState extends State<CVPersonalInfoScreen>
    with SingleTickerProviderStateMixin {
  final cvData = CVData();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final linkedInController = TextEditingController();
  final githubController = TextEditingController();
  final websiteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    linkedInController.dispose();
    githubController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text(
            "CV - Personal Info",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField('Full Name', nameController, Icons.person),
                  buildTextField('Email', emailController, Icons.email),
                  buildTextField('Phone Number', phoneController, Icons.phone),
                  buildTextField('Address', addressController, Icons.home),
                  buildTextField('LinkedIn', linkedInController, Icons.link),
                  buildTextField('GitHub', githubController, Icons.code),
                  buildTextField('Website/Portfolio', websiteController, Icons.web),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label,
      TextEditingController controller,
      IconData icon,
      ) {
    bool isPhoneField = label.toLowerCase().contains('phone');
    bool isEmail = label.toLowerCase().contains('email');

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextField(
        controller: controller,
        keyboardType: isPhoneField
            ? TextInputType.phone
            : isEmail
            ? TextInputType.emailAddress
            : TextInputType.text,
        onChanged: (_) => saveDataToModel(), // Live update to model
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void saveDataToModel() {
    cvData.name = nameController.text.trim();
    cvData.email = emailController.text.trim();
    cvData.phone = phoneController.text.trim();
    cvData.address = addressController.text.trim();
    cvData.linkedin = linkedInController.text.trim();
    cvData.github = githubController.text.trim();
    cvData.website = websiteController.text.trim();
  }
}
