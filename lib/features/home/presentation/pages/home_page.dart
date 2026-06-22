import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/challenge.dart';
import '../widgets/home_header.dart';
import '../widgets/pilar_card.dart';
import '../widgets/challenge_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final user = (context.watch<AuthBloc>().state as AuthAuthenticated?)?.user;
    final firstName = user?.name.split(' ').first ?? 'Gabriel';

    // Mock de desafio que viria do Firebase/Back
    const dailyChallenge = Challenge(
      id: '1',
      tag: 'Novo Desafio',
      title: 'Conquiste 500pts',
      description: 'Complete o módulo de Tesouro Direto.',
      points: 500,
      iconType: 'emoji_events',
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                user: user,
                firstName: firstName,
                subtitle: user?.league != null
                    ? 'Liga ${user!.league[0].toUpperCase()}${user.league.substring(1)}'
                    : 'Investidor Iniciante',
              ),
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
              ChallengeCard(challenge: dailyChallenge),
              const SizedBox(height: 40),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
                children: [
                  PilarCard(
                    icon: Icons.rocket_launch,
                    title: 'Praticar',
                    description: 'Simulador de mercado',
                    onTap: () => context.go(AppRoutes.games),
                  ),
                  PilarCard(
                    icon: Icons.school,
                    title: 'Aprender',
                    description: 'Trilha de aprendizado',
                    onTap: () => context.go(AppRoutes.content),
                  ),
                  PilarCard(
                    icon: Icons.track_changes,
                    title: 'Metas',
                    description: 'Acompanhe seus objetivos',
                    onTap: () => context.go(AppRoutes.missions),
                  ),
                  PilarCard(
                    icon: Icons.newspaper,
                    title: 'Notícias',
                    description: 'Últimas do mercado',
                    onTap: () => context.go(AppRoutes.news),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
