// lib/admin_dashboard_screen.dart

import 'package:flutter/cupertino.dart';

// Import the new tabs we will create
import 'admin_document_list_tab.dart';
import 'admin_upload_tab.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_on_doc_fill),
            label: 'My Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cloud_upload_fill),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bell_fill),
            label: 'Requests',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) {
                return const CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    middle: Text('My Uploaded Documents'),
                  ),
                  child:
                      AdminDocumentListTab(), // This is the list you had an error with
                );
              },
            );
          case 1:
            return CupertinoTabView(
              builder: (context) {
                return const CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    middle: Text('Upload New Document'),
                  ),
                  child: AdminUploadTab(), // We will create this next
                );
              },
            );
          case 2:
            return CupertinoTabView(
              builder: (context) {
                return const CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    middle: Text('Access Requests'),
                  ),
                  // We will build this screen later
                  child: Center(child: Text('Access Requests From Users')),
                );
              },
            );
          default:
            return const CupertinoTabView();
        }
      },
    );
  }
}
