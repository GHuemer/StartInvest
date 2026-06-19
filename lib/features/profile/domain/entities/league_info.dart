import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LeagueInfo extends Equatable {
  final String name;
  final int minXp;
  final Color color;
  final IconData icon;

  const LeagueInfo({
    required this.name,
    required this.minXp,
    required this.color,
    required this.icon,
  });

  @override
  List<Object?> get props => [name, minXp, color, icon];

  static const List<LeagueInfo> leagues = [
    LeagueInfo(
      name: 'bronze',
      minXp: 0,
      color: Color(0xFFCD7F32),
      icon: Icons.shield_outlined,
    ),
    LeagueInfo(
      name: 'prata',
      minXp: 500,
      color: Color(0xFFC0C0C0),
      icon: Icons.shield_outlined,
    ),
    LeagueInfo(
      name: 'ouro',
      minXp: 1500,
      color: Color(0xFFFFD700),
      icon: Icons.workspace_premium_outlined,
    ),
    LeagueInfo(
      name: 'elite',
      minXp: 3500,
      color: AppColors.primary,
      icon: Icons.diamond_outlined,
    ),
  ];

  static LeagueInfo getLeagueByXp(int xp) {
    return leagues.lastWhere(
      (league) => xp >= league.minXp,
      orElse: () => leagues.first,
    );
  }

  static LeagueInfo getLeagueByName(String name) {
    return leagues.firstWhere(
      (league) => league.name.toLowerCase() == name.toLowerCase(),
      orElse: () => leagues.first,
    );
  }
}
