/*
* ----------------- login_screen.dart -----------------
* Implements the clean, secure login interface.
*/
import 'package:flutter/cupertino.dart';
import 'home_router.dart'; // Import the router to navigate after login

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Function to simulate navigation after a successful login.
  void _login(BuildContext context, UserRole role) {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => HomeRouter(userRole: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. App Icon - Visually represents security.
              const Icon(
                CupertinoIcons.lock_shield_fill,
                size: 70,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              // App Name - Clear and bold.
              const Text(
                'EncryptiView',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 40),
              // 2. Email Input Field
              CupertinoTextField(
                placeholder: 'Email',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Icon(
                    CupertinoIcons.mail_solid,
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: CupertinoColors.systemGrey5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              // 3. Password Input Field
              CupertinoTextField(
                placeholder: 'Password',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Icon(
                    CupertinoIcons.lock_fill,
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
                obscureText: true,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: CupertinoColors.systemGrey5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 32),
              // 4. Login Buttons - One for each role for demonstration.
              CupertinoButton.filled(
                onPressed: () => _login(context, UserRole.viewer),
                child: const Text('Login as Viewer'),
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                color: CupertinoColors.systemGrey,
                onPressed: () => _login(context, UserRole.admin),
                child: const Text(
                  'Login as Admin',
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
