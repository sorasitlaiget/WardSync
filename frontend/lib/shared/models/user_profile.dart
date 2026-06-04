import 'enums.dart';

export 'enums.dart' show UserRole, TriageRoom;

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final TriageRoom? assignedRoom;
  final String? fcmToken;
  final bool isProfileComplete;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.assignedRoom,
    this.fcmToken,
    this.isProfileComplete = true,
  });

  bool get needsSetup {
    if (!isProfileComplete) return true;
    if (role == UserRole.doctor || role == UserRole.admin) {
      return assignedRoom == null;
    }
    return false;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        uid: json['uid'] as String,
        email: (json['email'] ?? '') as String,
        name: (json['name'] ?? json['displayName'] ?? '') as String,
        role: UserRole.values.byName((json['role'] ?? 'nurse') as String),
        assignedRoom: json['assignedRoom'] != null
            ? TriageRoom.values.byName(json['assignedRoom'] as String)
            : null,
        fcmToken: json['fcmToken'] as String?,
        isProfileComplete: json['isProfileComplete'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        'role': role.name,
        if (assignedRoom != null) 'assignedRoom': assignedRoom!.name,
        if (fcmToken != null) 'fcmToken': fcmToken,
      };
}
