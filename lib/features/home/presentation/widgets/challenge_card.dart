import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/challenge.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ChallengeCard({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.yellowHighlight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    challenge.tag.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTextStyles.fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(challenge.title, style: AppTextStyles.highlightTitle),
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  style: AppTextStyles.pilarDescription,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(challenge.iconType),
              color: Colors.amber,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'rocket':
        return Icons.rocket_launch;
      case 'school':
        return Icons.school;
      case 'emoji_events':
      default:
        return Icons.emoji_events;
    }
  }
}
