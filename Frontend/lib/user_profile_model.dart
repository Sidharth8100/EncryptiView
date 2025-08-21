// lib/user_profile_model.dart

class UserProfile {
  final int id;
  final String username;
  final String email;
  final bool adminApproved;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.adminApproved,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      adminApproved: json['admin_approved'],
    );
  }
}
