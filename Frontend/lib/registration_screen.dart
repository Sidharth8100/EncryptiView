// lib/registration_screen.dart

import 'package:flutter/cupertino.dart';
import 'api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  String _role = 'VIEWER'; // Default role
  bool _isLoading = false;

  void _register() async {
    // Basic validation
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showDialog('Validation Error', 'All fields are required.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _role,
      );
      _showDialog(
        'Success',
        _role == 'ADMIN'
            ? 'Account created. You can log in once a superuser approves your account.'
            : 'Account created successfully. You can now log in.',
        isSuccess: true,
      );
    } catch (e) {
      _showDialog(
        'Registration Failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog(String title, String content, {bool isSuccess = false}) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  if (isSuccess) {
                    Navigator.of(context).pop(); // Go back to the login screen
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Create Account'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CupertinoTextField(
              controller: _usernameController,
              placeholder: 'Username',
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _emailController,
              placeholder: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _passwordController,
              placeholder: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'I want to:',
              style: TextStyle(color: CupertinoColors.secondaryLabel),
            ),
            const SizedBox(height: 8),
            CupertinoSlidingSegmentedControl<String>(
              groupValue: _role,
              children: const {
                'VIEWER': Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Find Documents'),
                ),
                'ADMIN': Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Supply Documents'),
                ),
              },
              onValueChanged: (value) => setState(() => _role = value!),
            ),
            const SizedBox(height: 30),
            CupertinoButton.filled(
              onPressed: _isLoading ? null : _register,
              child:
                  _isLoading
                      ? const CupertinoActivityIndicator()
                      : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
