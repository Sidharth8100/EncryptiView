// lib/login_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'api_service.dart';
import 'document_viewer_screen.dart';
// THE FIX: This now imports the correct router, not the old flawed screen.
import 'home_router.dart';
import 'registration_screen.dart';

enum LoginMode { cloud, local }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String _errorMessage = '';
  LoginMode _selectedMode = LoginMode.cloud;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final Map<String, dynamic> loginData = await _apiService.login(
        _usernameController.text,
        _passwordController.text,
      );
      final String role = loginData['role'];
      final bool isSuperuser = loginData['is_superuser'] ?? false;
      final bool adminApproved = loginData['admin_approved'] ?? false;

      if (mounted) {
        // THE FIX: This now navigates directly to the HomeRouter, which handles everything.
        // This removes the broken intermediate screen.
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder:
                (_) => HomeRouter(
                  role: role,
                  isSuperuser: isSuperuser,
                  adminApproved: adminApproved,
                ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _browseLocalFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
      );
      if (result != null && result.files.single.path != null) {
        final String filePath = result.files.single.path!;
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DocumentViewerScreen(localFilePath: filePath),
            ),
          );
        }
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              const Icon(
                CupertinoIcons.lock_shield_fill,
                size: 70,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              const Text(
                'EncryptiView',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),
              CupertinoSlidingSegmentedControl<LoginMode>(
                groupValue: _selectedMode,
                onValueChanged: (LoginMode? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedMode = newValue);
                  }
                },
                children: const <LoginMode, Widget>{
                  LoginMode.cloud: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('Secure Cloud'),
                  ),
                  LoginMode.local: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('Local Viewer'),
                  ),
                },
              ),
              const SizedBox(height: 32),
              _buildSelectedModeWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedModeWidget() {
    if (_selectedMode == LoginMode.local) {
      return Column(
        children: [
          const Icon(
            CupertinoIcons.folder_fill,
            size: 50,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'View documents stored on your device.',
            textAlign: TextAlign.center,
            style: TextStyle(color: CupertinoColors.secondaryLabel),
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _browseLocalFiles,
            child: const Text('Browse Local Files'),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CupertinoTextField(
            controller: _usernameController,
            placeholder: 'Username',
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _passwordController,
            placeholder: 'Password',
            obscureText: true,
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CupertinoColors.destructiveRed,
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _isLoading ? null : _handleLogin,
            child:
                _isLoading
                    ? const CupertinoActivityIndicator()
                    : const Text('Login'),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const RegistrationScreen()),
              );
            },
            child: const Text('Create an Account'),
          ),
        ],
      );
    }
  }
}
