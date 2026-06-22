import 'package:flutter/material.dart';
import '../../domain/entities/mission_entity.dart';

class MissionModel extends MissionEntity {
  const MissionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.icon,
    required super.category,
    super.status,
    super.requiredLevel,
    super.requiredCourses,
    super.progress,
    super.rewardPoints,
  });

  factory MissionModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    return MissionModel(
      id: documentId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: _getIconData(json['icon'] ?? ''),
      category: _parseCategory(json['category'] ?? ''),
      requiredLevel: json['requiredLevel'] ?? 0,
      requiredCourses: json['requiredCourses'] ?? 0,
      rewardPoints: json['rewardPoints'] ?? 50,
    );
  }

  static MissionCategory _parseCategory(String category) {
    switch (category) {
      case 'learning':
        return MissionCategory.learning;
      case 'practice':
        return MissionCategory.practice;
      default:
        return MissionCategory.learning;
    }
  }

  static IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'play': return Icons.play_circle_outline;
      case 'book': return Icons.menu_book;
      case 'trending': return Icons.trending_up;
      case 'pie': return Icons.pie_chart;
      case 'bank': return Icons.account_balance;
      case 'savings': return Icons.savings;
      case 'calendar': return Icons.calendar_today;
      case 'analytics': return Icons.analytics;
      case 'waves': return Icons.waves;
      case 'school': return Icons.school;
      default: return Icons.emoji_events;
    }
  }
}
