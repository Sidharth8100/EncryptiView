// lib/main.dart

import 'package:flutter/material.dart'; // Use Material as the foundation
import 'login_screen.dart';

void main() {
  runApp(const EncryptiViewApp());
}

class EncryptiViewApp extends StatelessWidget {
  const EncryptiViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MaterialApp as the one and only app root.
    return MaterialApp(
      title: 'EncryptiView',
      debugShowCheckedModeBanner: false,
      // We can define a theme that uses Cupertino-style page transitions
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // The app starts at the LoginScreen.
      home: const LoginScreen(),
    );
  }
}
