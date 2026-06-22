import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum MissionCategory { all, learning, practice }

enum MissionStatus { locked, available, completed }

class MissionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final MissionCategory category;
  final MissionStatus status;
  final int requiredLevel;
  final int requiredCourses;
  final double progress; // 0.0 to 1.0
  final int rewardPoints; // Quantos pontos o jogador ganha ao completar

  const MissionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.status = MissionStatus.locked,
    this.requiredLevel = 0,
    this.requiredCourses = 0,
    this.progress = 0.0,
    this.rewardPoints = 50, // Padrão de 50 pontos para as antigas
  });

  bool get isLocked => status == MissionStatus.locked;
  bool get isCompleted => status == MissionStatus.completed;

  MissionEntity copyWith({
    MissionStatus? status,
    double? progress,
  }) {
    return MissionEntity(
      id: id,
      title: title,
      description: description,
      icon: icon,
      category: category,
      status: status ?? this.status,
      requiredLevel: requiredLevel,
      requiredCourses: requiredCourses,
      progress: progress ?? this.progress,
      rewardPoints: rewardPoints,
    );
  }

  @override
  List<Object?> get props => [id, title, description, icon, category, status, requiredLevel, requiredCourses, progress, rewardPoints];
}
