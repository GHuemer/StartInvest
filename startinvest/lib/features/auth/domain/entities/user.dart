import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.xp = 0,
    this.level = 1,
    this.league = 'bronze',
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final int xp;
  final int level;
  final String league;

  @override
  List<Object?> get props => [id, name, email, photoUrl, xp, level, league];
}
