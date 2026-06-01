import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/mission_entity.dart';

class MissionCard extends StatelessWidget {
  final MissionEntity mission;

  const MissionCard({super.key, required this.mission});

  String _getRequirementText() {
    List<String> reqs = [];
    if (mission.requiredLevel > 0) reqs.add('Nível ${mission.requiredLevel}');
    if (mission.requiredCourses > 0) reqs.add('${mission.requiredCourses} cursos');
    
    if (reqs.isEmpty) return 'Bloqueado';
    return 'Requisito: ${reqs.join(' + ')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = mission.isLocked;
    final bool isCompleted = mission.isCompleted;
    final bool hasProgress = !isLocked && !isCompleted && mission.progress > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: isLocked ? Border.all(color: AppColors.divider.withOpacity(0.5)) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLocked ? Icons.lock_outline : mission.icon,
            color: isLocked ? AppColors.textMuted.withOpacity(0.5) : AppColors.accent,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            mission.title,
            style: AppTextStyles.titleMedium.copyWith(
              color: isLocked ? AppColors.textMuted : null,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            isLocked ? _getRequirementText() : mission.description,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: isLocked ? AppColors.primary.withOpacity(0.7) : AppColors.textMuted,
              fontWeight: isLocked ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isCompleted) ...[
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                SizedBox(width: 4),
                Text(
                  'Completado',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ] else if (hasProgress) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: mission.progress,
                minHeight: 6,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
