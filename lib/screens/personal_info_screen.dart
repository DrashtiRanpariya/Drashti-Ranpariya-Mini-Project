import 'package:flutter/material.dart';
import '../models/resume_data.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  PersonalInfoScreenState createState() => PersonalInfoScreenState();
}

class PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final resumeData = ResumeData();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final linkedInController = TextEditingController();
  final githubController = TextEditingController();
  final websiteController = TextEditingController();

  bool saveData() {
    if (_formKey.currentState?.validate() ?? false) {
      resumeData.name = nameController.text;
      resumeData.email = emailController.text;
      resumeData.phone = phoneController.text;
      resumeData.address = addressController.text;
      resumeData.linkedin = addressController.text;
      resumeData.github = addressController.text;
      resumeData.website = addressController.text;

      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Personal Information',
          style: TextStyle(color: Colors.white), // ✅ Bright white
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // ✅ Back icon white
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    buildTextField('Full Name', nameController, Icons.person, true),
                    buildTextField('Email', emailController, Icons.email, true, isEmail: true),
                    buildTextField('Phone Number', phoneController, Icons.phone, true),
                    buildTextField('Address', addressController, Icons.home, true),
                    buildTextField('LinkedIn', linkedInController, Icons.link, false),
                    buildTextField('GitHub', githubController, Icons.code, false),
                    buildTextField('Website/Portfolio', websiteController, Icons.web, false),
                    // SizedBox(height: 30),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.deepPurple,
                    //     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //   ),
                    //   onPressed: _saveAndNext,
                    //   child: Text(
                    //     'Next',
                    //     style: TextStyle(
                    //       fontSize: 18,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 10),
            // Text(
            //   "Developed by Dhrashti Ranpariya",
            //   style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey[700]),
            // ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      String label,
      TextEditingController controller,
      IconData icon,
      bool isRequired, {
        bool isEmail = false,
      }) {
    bool isPhoneField = label.toLowerCase().contains('phone');

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isPhoneField
            ? TextInputType.phone
            : isEmail
            ? TextInputType.emailAddress
            : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          if (isEmail && value != null && !value.contains('@')) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }
}
