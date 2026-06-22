import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.email,
    super.photoUrl,
    super.birthDate,
    super.xp,
    super.level,
    super.league,
    super.subtitle,
    super.isNewUser,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      birthDate: map['birthDate'] != null
          ? (map['birthDate'] as Timestamp).toDate()
          : null,
      xp: (map['xp'] ?? 0) as int,
      level: (map['level'] ?? 1) as int,
      league: map['league'] ?? 'bronze',
      subtitle: map['subtitle'] ?? 'Investidor Iniciante',
      isNewUser: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'xp': xp,
      'level': level,
      'league': league,
      'subtitle': subtitle,
    };
  }

  /// Converte o objeto do Firebase Auth para o nosso UserModel
  /// Nota: O username precisará ser preenchido após o login social se for a primeira vez
  factory UserModel.fromFirebaseUser(
    dynamic firebaseUser, {
    String? username,
    bool isNewUser = false,
  }) {
    return UserModel(
      id: firebaseUser.uid,
      username: username ?? '',
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      birthDate: null,
      isNewUser: isNewUser,
    );
  }
}
