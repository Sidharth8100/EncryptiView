/*
* ----------------- home_router.dart -----------------
* A simple router to direct the user based on their assigned role.
*/
import 'package:flutter/widgets.dart';
import 'admin_home.dart';
import 'viewer_home.dart';

// Enum to define user roles for the demo.
enum UserRole { admin, viewer }

class HomeRouter extends StatelessWidget {
  final UserRole userRole;
  const HomeRouter({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    // Switch between dashboards based on the user's role.
    switch (userRole) {
      case UserRole.admin:
        return const AdminHome();
      case UserRole.viewer:
        return const ViewerHome();
    }
  }
}
