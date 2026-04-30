import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildDailyMission(context)),
            SliverToBoxAdapter(child: _buildQuickAccess(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = (context.watch<AuthBloc>().state as AuthAuthenticated?)?.user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(text: 'START', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.white)),
                      TextSpan(text: ' INVEST', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400, color: AppColors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text('Olá, ${user?.name.split(' ').first ?? 'Investidor'}!', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 4),
                Text('Nível ${user?.level ?? 1} - Investidor Iniciante 🚀', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.backgroundCardLight,
              backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null ? const Icon(Icons.person, color: AppColors.textSecondary) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMission(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Missão Diária', style: AppTextStyles.titleLarge),
                Text('+ 20 pontos', style: AppTextStyles.xpLabel),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Leia um artigo sobre juros compostos', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.content),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                child: const Text('Iniciar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    final items = [
      _QuickItem(
        title: 'Praticar',
        subtitle: 'Simuladores e Desafios Reais.',
        icon: Icons.monetization_on,
        iconColor: const Color(0xFF9C27B0),
        route: AppRoutes.games,
      ),
      _QuickItem(
        title: 'Aprender',
        subtitle: 'Cursos e Guias para o seu Nível.',
        icon: Icons.menu_book,
        iconColor: const Color(0xFFFF9800),
        route: AppRoutes.content,
      ),
      _QuickItem(
        title: 'Metas',
        subtitle: 'Defina e Acompanhe seus Objetivos.',
        icon: Icons.track_changes,
        iconColor: const Color(0xFFE53935),
        route: AppRoutes.missions,
      ),
      _QuickItem(
        title: 'Notícias',
        subtitle: 'O Mercado em Tempo Real.',
        icon: Icons.language,
        iconColor: const Color(0xFF1E88E5),
        route: AppRoutes.news,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: items.map((item) => _buildQuickCard(context, item)).toList(),
      ),
    );
  }

  Widget _buildQuickCard(BuildContext context, _QuickItem item) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: AppTextStyles.titleLarge),
            const Spacer(),
            Icon(item.icon, color: item.iconColor, size: 40),
            const Spacer(),
            Text(item.subtitle, style: AppTextStyles.bodySmall, maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _QuickItem {
  const _QuickItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String route;
}
