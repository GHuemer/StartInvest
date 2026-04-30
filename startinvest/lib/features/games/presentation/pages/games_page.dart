import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    const BackButton(),
                    const Text('Jogos', style: AppTextStyles.headlineLarge),
                    const Spacer(),
                    CircleAvatar(radius: 18, backgroundColor: AppColors.backgroundCard, child: const Icon(Icons.person, size: 18, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Ex: Quiz Renda Fixa',
                    prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: const Text('Seus jogos favoritos', style: AppTextStyles.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('Quiz! • Duelo dos Investimentos', style: AppTextStyles.bodyMedium)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: const Text('Jogue com base no risco', style: AppTextStyles.headlineMedium),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _RiskCard(icon: Icons.shield_outlined, title: 'Conservador', subtitle: 'Baixo risco, retorno baixo', color: AppColors.primary),
                _RiskCard(icon: Icons.balance, title: 'Moderado', subtitle: 'Equilíbrio entre risco e retorno', color: AppColors.accent),
                _RiskCard(icon: Icons.rocket_launch_outlined, title: 'Agressivo', subtitle: 'Risco alto, retorno potencialmente maior', color: AppColors.accentOrange),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.icon, required this.title, required this.subtitle, required this.color});
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleLarge),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
