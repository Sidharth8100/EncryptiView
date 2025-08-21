// lib/home_router.dart

import 'package:flutter/cupertino.dart';

import 'admin_dashboard_screen.dart';
import 'login_screen.dart';
import 'superuser_dashboard_screen.dart';
import 'viewer_home.dart';

class HomeRouter extends StatelessWidget {
  final String role;
  final bool isSuperuser;
  final bool adminApproved;

  const HomeRouter({
    super.key,
    required this.role,
    required this.isSuperuser,
    required this.adminApproved,
  });

  @override
  Widget build(BuildContext context) {
    if (isSuperuser) {
      return const SuperuserDashboardScreen();
    }

    if (role == 'ADMIN') {
      if (adminApproved) {
        return const AdminDashboardScreen();
      } else {
        // This is the correct place for the "Pending Approval" screen.
        return CupertinoPageScaffold(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.time,
                    size: 60,
                    color: CupertinoColors.systemOrange,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Account Pending Approval',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your supplier account is awaiting approval from a superuser. Please check back later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  CupertinoButton.filled(
                    child: const Text('Logout'),
                    onPressed: () {
                      // Add real logout logic here (clear secure storage)
                      Navigator.of(context).pushReplacement(
                        CupertinoPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // Default for any other role, like 'VIEWER'
    return const ViewerHome();
  }
}
