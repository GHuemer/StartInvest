import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MissionsPage extends StatelessWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      _Badge('Primeiro Passo', 'Complete sua primeira missão', Icons.emoji_events, AppColors.accent, true),
      _Badge('Estudioso', 'Complete 5 módulos', Icons.star, AppColors.accent, true),
      _Badge('Investidor Iniciante', 'Crie seu primeiro portfólio', Icons.trending_up, AppColors.accent, true),
      _Badge('Investidor Experiente', 'Complete 20 módulos\n+ 300 pontos', Icons.lock, AppColors.textMuted, false),
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(children: [const BackButton(), const Text('Metas', style: AppTextStyles.headlineLarge)]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progresso: 3/100', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: 3 / 100, minHeight: 8, backgroundColor: AppColors.divider),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Row(
                  children: [
                    _FilterChip(label: 'Tudo', selected: true),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Aprendizado', selected: false),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Prática', selected: false),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _BadgeCard(badge: badges[i]),
                  childCount: badges.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge {
  const _Badge(this.title, this.subtitle, this.icon, this.color, this.unlocked);
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final bool unlocked;
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(badge.icon, color: badge.color, size: 40),
          const SizedBox(height: 8),
          Text(badge.title, style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(badge.subtitle, style: AppTextStyles.bodySmall, textAlign: TextAlign.center, maxLines: 2),
          if (badge.unlocked) ...[
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                SizedBox(width: 4),
                Text('Completado', style: TextStyle(color: AppColors.primary, fontSize: 11)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
      ),
      child: Text(label, style: TextStyle(color: selected ? AppColors.white : AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}
