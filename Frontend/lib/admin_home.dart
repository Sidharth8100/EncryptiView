// lib/admin_home.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For MaterialPageRoute
import 'admin_document_list_tab.dart'; // Import our new tab widget
import 'login_screen.dart';
import 'secure_storage_service.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  Future<void> _logout(BuildContext context) async {
    final storage = SecureStorageService();
    await storage.deleteAll();
    if (context.mounted) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_on_doc_fill),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group_solid),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bell_fill),
            label: 'Requests',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            final String title;
            final Widget child;

            switch (index) {
              case 0:
                title = 'All Documents';
                child = const AdminDocumentListTab(); // Use our new widget
                break;
              case 1:
                title = 'Users';
                child = const Center(
                  child: Text('User Management Coming Soon'),
                );
                break;
              case 2:
                title = 'Access Requests';
                child = const Center(
                  child: Text('Access Requests Coming Soon'),
                );
                break;
              default:
                title = 'Admin';
                child = const Center(child: Text('Welcome, Admin!'));
            }

            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text(title),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _logout(context),
                  child: const Text('Logout'),
                ),
              ),
              child: child,
            );
          },
        );
      },
    );
  }
}
