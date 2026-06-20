import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String username;
  final String name;
  final String email;
  final String? photoUrl;
  final int xp;
  final int level;
  final String league;
  final String subtitle;
  final int completedCoursesCount;
  final double balance;
  final int assetTypesCount;
  final int loginStreak;
  final List<String> completedMissionsIds;
  final List<String> friendIds;
  final String memberSince; // This might be derived from Auth or another field

  const UserProfile({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.xp,
    required this.level,
    required this.league,
    required this.subtitle,
    required this.completedCoursesCount,
    required this.balance,
    required this.assetTypesCount,
    required this.loginStreak,
    required this.completedMissionsIds,
    this.friendIds = const [],
    required this.memberSince,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        name,
        email,
        photoUrl,
        xp,
        level,
        league,
        subtitle,
        completedCoursesCount,
        balance,
        assetTypesCount,
        loginStreak,
        completedMissionsIds,
        friendIds,
        memberSince,
      ];

  UserProfile copyWith({
    String? username,
    String? name,
    String? photoUrl,
    int? xp,
    int? level,
    String? league,
    String? subtitle,
    int? completedCoursesCount,
    double? balance,
    int? assetTypesCount,
    int? loginStreak,
    List<String>? completedMissionsIds,
    List<String>? friendIds,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      league: league ?? this.league,
      subtitle: subtitle ?? this.subtitle,
      completedCoursesCount: completedCoursesCount ?? this.completedCoursesCount,
      balance: balance ?? this.balance,
      assetTypesCount: assetTypesCount ?? this.assetTypesCount,
      loginStreak: loginStreak ?? this.loginStreak,
      completedMissionsIds: completedMissionsIds ?? this.completedMissionsIds,
      friendIds: friendIds ?? this.friendIds,
      memberSince: memberSince,
    );
  }
}
