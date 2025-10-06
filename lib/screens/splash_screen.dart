import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()), // removed const
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // colors (match your app theme)
    final Color bg = Colors.indigo.shade600;
    final Color titleColor = Colors.white;
    final Color subtitleColor = Colors.white70;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Center content: icon above app name
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Try loading launcher icon asset. If not present, show fallback avatar.
                  // Put your launcher icon at: assets/icons/launcher.png
                  // and add it to pubspec.yaml under flutter -> assets:
                  //   - assets/icons/launcher.png
                  Image.asset(
                    'assets/icons/launcher.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.contain,
                    // if asset not found or fails to load, show a nice fallback
                    errorBuilder: (context, error, stackTrace) {
                      return CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        child: Text(
                          'QC', // QuickCV initials
                          style: TextStyle(
                            color: bg,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'QuickCV',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // footer text
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Developed by Drashti Ranpariya',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}