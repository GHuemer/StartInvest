import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GamesHubPage extends StatelessWidget {
  const GamesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        title: Text(
          'Praticar',
          style: AppTextStyles.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Predictor',
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Veja uma situação de mercado e preveja se as ações vão subir ou descer.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            _DifficultySelector(
              difficulty: 'easy',
              title: 'Fácil',
              description: 'Histórias claras com indicadores óbvios',
              maxPoints: 30,
              onPressed: () => _startGame(context, 'easy'),
            ),
            const SizedBox(height: 16),
            _DifficultySelector(
              difficulty: 'medium',
              title: 'Médio',
              description: 'Situações com múltiplas variáveis',
              maxPoints: 50,
              onPressed: () => _startGame(context, 'medium'),
            ),
            const SizedBox(height: 16),
            _DifficultySelector(
              difficulty: 'hard',
              title: 'Difícil',
              description: 'Cenários complexos com nuances de mercado',
              maxPoints: 70,
              onPressed: () => _startGame(context, 'hard'),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, String difficulty) {
    context.push('${AppRoutes.games}/market-predictor/$difficulty');
  }
}

class _DifficultySelector extends StatelessWidget {
  final String difficulty;
  final String title;
  final String description;
  final int maxPoints;
  final VoidCallback onPressed;

  const _DifficultySelector({
    required this.difficulty,
    required this.title,
    required this.description,
    required this.maxPoints,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      'easy' => AppColors.primary,
      'medium' => AppColors.yellowHighlight,
      'hard' => AppColors.accentOrange,
      _ => AppColors.primary,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: color,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Máx: $maxPoints pontos',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
