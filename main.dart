import 'package:flutter/cupertino.dart';
import 'login_screen.dart'; // Import the login screen

void main() {
  runApp(const EncryptiViewApp());
}

class EncryptiViewApp extends StatelessWidget {
  const EncryptiViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'EncryptiView',
      // The theme is set to Cupertino defaults, matching the design spec.
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.activeBlue,
      ),
      debugShowCheckedModeBanner: false,
      // The app starts at the LoginScreen.
      home: LoginScreen(),
    );
  }
}
