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
    final user = (context.watch<AuthBloc>().state as AuthAuthenticated?)?.user;
    final firstName = user?.name.split(' ').first ?? 'Gabriel';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, user, firstName),
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 40),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
                children: [
                  _PilarCard(
                    icon: Icons.rocket_launch,
                    title: 'Praticar',
                    description: 'Simulador de mercado em tempo real',
                    onTap: () => context.go(AppRoutes.games),
                  ),
                  _PilarCard(
                    icon: Icons.school,
                    title: 'Aprender',
                    description: 'Cursos e trilhas de investimento',
                    iconColor: const Color(0xFFF1C40F),
                    onTap: () => context.go(AppRoutes.content),
                  ),
                  _PilarCard(
                    icon: Icons.emoji_events,
                    title: 'Metas',
                    description: 'Acompanhe seus objetivos',
                    onTap: () => context.go(AppRoutes.missions),
                  ),
                  _PilarCard(
                    icon: Icons.newspaper,
                    title: 'Notícias',
                    description: 'Últimas do mercado financeiro',
                    onTap: () => context.go(AppRoutes.news),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildChallengeCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, String firstName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start Invest',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: AppTextStyles.fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Bem-vindo de volta,', style: AppTextStyles.greeting),
            const SizedBox(height: 4),
            Text('Olá, $firstName!', style: AppTextStyles.userName),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.backgroundCard,
                child: ClipOval(
                  child: user?.photoUrl != null
                      ? Image.network(user!.photoUrl!)
                      : const Icon(Icons.person_outline, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChallengeCard() {
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
                  child: const Text(
                    'NOVO DESAFIO',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTextStyles.fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Conquiste 500pts', style: AppTextStyles.highlightTitle),
                const SizedBox(height: 4),
                const Text(
                  'Complete o módulo de Tesouro Direto.',
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
            child: const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
          ),
        ],
      ),
    );
  }
}

class _PilarCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;
  final VoidCallback onTap;

  const _PilarCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(title, style: AppTextStyles.pilarTitle),
            const SizedBox(height: 6),
            Text(
              description,
              style: AppTextStyles.pilarDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
