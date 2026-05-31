import '../../domain/entities/user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
    super.xp,
    super.level,
    super.league,
    super.subtitle,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      xp: (map['xp'] ?? 0) as int,
      level: (map['level'] ?? 1) as int,
      league: map['league'] ?? 'bronze',
      subtitle: map['subtitle'] ?? 'Investidor Iniciante',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'xp': xp,
      'level': level,
      'league': league,
      'subtitle': subtitle,
    };
  }

  /// Converte o objeto do Firebase Auth para o nosso UserModel
  /// O Junior do Back vai usar isso no Repository
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
    );
  }
}
