import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.photoUrl,
    this.birthDate,
    this.xp = 0,
    this.level = 1,
    this.league = 'bronze',
    this.subtitle = 'Investidor Iniciante',
    this.isNewUser = false,
  });

  final String id;
  final String username; // Nome de usuário único para adicionar amigos
  final String name; // Apelido / Nome de exibição
  final String email;
  final String? photoUrl;
  final DateTime? birthDate;
  final int xp;
  final int level;
  final String league;
  final String subtitle;
  final bool isNewUser;

  AppUser copyWith({
    String? username,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? birthDate,
    int? xp,
    int? level,
    String? league,
    String? subtitle,
    bool? isNewUser,
  }) {
    return AppUser(
      id: id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      league: league ?? this.league,
      subtitle: subtitle ?? this.subtitle,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  @override
  List<Object?> get props => [id, username, name, email, photoUrl, birthDate, xp, level, league, subtitle, isNewUser];
}
