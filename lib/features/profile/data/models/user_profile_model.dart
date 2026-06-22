import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.username,
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
    final data = doc.data() as Map<String, dynamic>? ?? {};

    String parsedMemberSince =
        'junho de 2026'; // Fallback para usuários antigos
    if (data['createdAt'] is Timestamp) {
      final date = (data['createdAt'] as Timestamp).toDate();
      const months = [
        'janeiro',
        'fevereiro',
        'março',
        'abril',
        'maio',
        'junho',
        'julho',
        'agosto',
        'setembro',
        'outubro',
        'novembro',
        'dezembro',
      ];
      parsedMemberSince = '${months[date.month - 1]} de ${date.year}';
    } else if (data['memberSince'] != null &&
        data['memberSince'].toString().isNotEmpty) {
      // Ignoramos a string antiga que foi injetada no banco por engano antes da atualização
      if (data['memberSince'] != 'novembro de 2025') {
        parsedMemberSince = data['memberSince'];
      }
    }

    return UserProfileModel(
      id: doc.id,
      username: data['username'] ?? '',
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
      completedMissionsIds: List<String>.from(
        data['completedMissionsIds'] ?? [],
      ),
      friendIds: List<String>.from(data['friendIds'] ?? []),
      memberSince: parsedMemberSince,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
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
