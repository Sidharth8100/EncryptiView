import 'package:flutter/cupertino.dart';
import 'login_screen.dart'; // For logout functionality

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    // TabScaffold is the standard Cupertino widget for a tabbed interface.
    return CupertinoTabScaffold(
      // 1. Tab Bar - Defines the navigation items at the bottom.
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
            icon: Icon(CupertinoIcons.chart_bar_alt_fill),
            label: 'Analytics',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        // Each tab has its own navigation stack, provided by CupertinoTabView.
        return CupertinoTabView(
          builder: (context) {
            // Determine the title for the navigation bar based on the selected tab.
            final title = ['Documents', 'Users', 'Analytics'][index];
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text(title),
                // Show an 'add' button only on the Documents tab.
                trailing:
                    index == 0
                        ? CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.add),
                          onPressed: () {
                            /* TODO: Initiate document upload flow */
                          },
                        )
                        : CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushReplacement(
                              CupertinoPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text('Logout'),
                        ),
              ),
              child: Center(
                child: Text(
                  'Content for $title',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
