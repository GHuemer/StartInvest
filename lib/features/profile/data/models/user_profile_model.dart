import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
    required super.xp,
    required super.level,
    required super.league,
    required super.subtitle,
    required super.completedCoursesCount,
    required super.balance,
    required super.assetTypesCount,
    required super.loginStreak,
    required super.completedMissionsIds,
    super.friendIds,
    required super.memberSince,
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      league: data['league'] ?? 'bronze',
      subtitle: data['subtitle'] ?? 'Investidor Iniciante',
      completedCoursesCount: data['completedCoursesCount'] ?? 0,
      balance: (data['balance'] ?? 0.0).toDouble(),
      assetTypesCount: data['assetTypesCount'] ?? 0,
      loginStreak: data['loginStreak'] ?? 0,
      completedMissionsIds: List<String>.from(data['completedMissionsIds'] ?? []),
      friendIds: List<String>.from(data['friendIds'] ?? []),
      memberSince: data['memberSince'] ?? 'novembro de 2025', // Should probably be a timestamp in production
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'xp': xp,
      'level': level,
      'league': league,
      'subtitle': subtitle,
      'completedCoursesCount': completedCoursesCount,
      'balance': balance,
      'assetTypesCount': assetTypesCount,
      'loginStreak': loginStreak,
      'completedMissionsIds': completedMissionsIds,
      'friendIds': friendIds,
      'memberSince': memberSince,
    };
  }
}
