// lib/superuser_dashboard_screen.dart

import 'package:flutter/cupertino.dart';

class SuperuserDashboardScreen extends StatelessWidget {
  const SuperuserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Superuser Panel')),
      child: Center(child: Text('Superuser Features Here')),
    );
  }
}
