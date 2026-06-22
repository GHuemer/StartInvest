import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../domain/entities/quiz_question.dart';
import 'category_games_page.dart';
import 'portfolio_hub_page.dart';
import 'projection_setup_page.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: const AppBackButton(),
        title: const Text('Jogos', style: AppTextStyles.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // ── Busca ──────────────────────────────────────────────────────
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ex: Quiz Renda Fixa',
                hintStyle:
                    const TextStyle(color: Colors.white54, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: AppColors.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 28),
            // ── Praticar ───────────────────────────────────────────────────
            const Text(
              'Praticar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _GameCard(
              icon: Icons.query_stats,
              title: 'Market Predictor',
              subtitle: 'Preveja os movimentos do mercado',
              onTap: () => context.push('/games/market-predictor'),
            ),
            const SizedBox(height: 28),
            // ── Filtro por risco ───────────────────────────────────────────
            const Text(
              'Jogue com base no risco',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _RiskCard(
              title: 'Conservador',
              subtitle: 'Baixo risco, retorno baixo',
              icon: Icons.shield_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryGamesPage(
                    difficulty: QuizDifficulty.conservative,
                  ),
                ),
              ),
            ),
            _RiskCard(
              title: 'Moderado',
              subtitle: 'Equilíbrio entre risco e retorno',
              icon: Icons.balance,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryGamesPage(
                    difficulty: QuizDifficulty.moderate,
                  ),
                ),
              ),
            ),
            _RiskCard(
              title: 'Agressivo',
              subtitle: 'Risco alto, retorno potencialmente maior',
              icon: Icons.rocket_launch_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryGamesPage(
                    difficulty: QuizDifficulty.aggressive,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            // ── Simuladores ────────────────────────────────────────────────
            const Text(
              'Simuladores',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _GameCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Simulador de Investimentos',
              subtitle:
                  'Compre e venda Ações, FIIs e Renda Fixa com dinheiro virtual. Ganhe XP com seus lucros!',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PortfolioHubPage()),
              ),
            ),
            const SizedBox(height: 12),
            _GameCard(
              icon: Icons.show_chart,
              title: 'Projetor de Investimentos',
              subtitle:
                  'Simule quanto seu dinheiro pode render no futuro com base no histórico real.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ProjectionSetupPage()),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GameCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RiskCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.cardBorder.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
