import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../ranking/presentation/bloc/ranking_cubit.dart';
import '../../../ranking/presentation/bloc/ranking_state.dart';
import '../../../profile/domain/entities/user_profile.dart';
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
    final firstName = user?.name.split(' ').first ?? 'Investidor';
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    const activeChallenge = Challenge(
      id: '1',
      tag: 'Desafio Ativo',
      title: 'Conquiste 500 XP',
      description: 'Finalize o módulo de Tesouro Direto com aproveitamento superior a 90%.',
      points: 500,
      iconType: 'emoji_events',
    );

    if (isDesktop) {
      return _DesktopHome(user: user, firstName: firstName, activeChallenge: activeChallenge);
    }
    return _MobileHome(user: user, firstName: firstName, activeChallenge: activeChallenge);
  }
}

// ─── Desktop ─────────────────────────────────────────────────────────────────

class _DesktopHome extends StatelessWidget {
  final dynamic user;
  final String firstName;
  final Challenge activeChallenge;

  const _DesktopHome({required this.user, required this.firstName, required this.activeChallenge});

  @override
  Widget build(BuildContext context) {
    final rankingState = context.watch<RankingCubit>().state;

    final int level = user?.level ?? 1;
    final String league = user?.league ?? 'bronze';
    final String subtitle = user?.subtitle ?? 'Investidor Iniciante';

    List<UserProfile> rankingEntries = [];
    if (rankingState is RankingLoaded && user != null) {
      final global = rankingState.globalRanking;
      final idx = global.indexWhere((u) => u.id == user.id);
      if (idx >= 0) {
        final start = ((idx - 1) as num).clamp(0, global.length - 1).toInt();
        final end = ((idx + 2) as num).clamp(0, global.length).toInt();
        rankingEntries = global.sublist(start, end);
      } else {
        rankingEntries = global.take(3).toList();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(40, 32, 40, 32),
              child: SizedBox(
                height: constraints.maxHeight - 64,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 10,
                      child: _LeftColumn(
                        firstName: firstName,
                        subtitle: subtitle,
                        level: level,
                        activeChallenge: activeChallenge,
                      ),
                    ),
                    const SizedBox(width: 28),
                    SizedBox(
                      width: 300,
                      child: _RightColumn(
                        league: league,
                        user: user,
                        rankingEntries: rankingEntries,
                        rankingState: rankingState,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Left column ─────────────────────────────────────────────────────────────

class _LeftColumn extends StatelessWidget {
  final String firstName;
  final String subtitle;
  final int level;
  final Challenge activeChallenge;

  const _LeftColumn({
    required this.firstName,
    required this.subtitle,
    required this.level,
    required this.activeChallenge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Greeting ──────────────────────────────────────────────────────
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                subtitle.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontSize: 10, letterSpacing: 1),
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text('Nível $level', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        Text('Olá, $firstName!', style: AppTextStyles.userName.copyWith(fontSize: 44)),
        const SizedBox(height: 8),
        Text(
          'Você está evoluindo rápido. Continue sua jornada para atingir a meta de XP desta semana.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 24),

        // ── APRENDER section header ────────────────────────────────────────
        _SectionHeader(title: 'APRENDER', action: 'VER CURSOS', onTap: () => context.go(AppRoutes.content)),
        const SizedBox(height: 12),

        // ── Course card — grows to fill flex:2 ────────────────────────────
        Expanded(
          flex: 2,
          child: _CourseCard(),
        ),
        const SizedBox(height: 16),

        // ── Bottom row: Simulador + Desafio Ativo — grows to fill flex:3 ──
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _SimuladorCard()),
              const SizedBox(width: 16),
              Expanded(child: _DesafioAtivoCard(challenge: activeChallenge)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.school_outlined, color: AppColors.primary, size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bolsa de Valores para Iniciantes',
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Módulo 3: Entendendo o Home Broker',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 0.65,
                              backgroundColor: AppColors.backgroundCardLight,
                              color: AppColors.primary,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('65% concluído', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.content),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.textBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Continuar', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textBlack, fontSize: 14)),
                      const SizedBox(width: 5),
                      const Icon(Icons.play_arrow, size: 16, color: AppColors.textBlack),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Module list
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _ModuleChip(index: 1, label: 'O que é a bolsa?', done: true),
              const SizedBox(width: 12),
              _ModuleChip(index: 2, label: 'Tipos de ações', done: true),
              const SizedBox(width: 12),
              _ModuleChip(index: 3, label: 'Home Broker', done: false, active: true),
              const SizedBox(width: 12),
              _ModuleChip(index: 4, label: 'Order flow', done: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleChip extends StatelessWidget {
  final int index;
  final String label;
  final bool done;
  final bool active;

  const _ModuleChip({required this.index, required this.label, this.done = false, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.12)
              : done
                  ? AppColors.backgroundCardLight
                  : AppColors.backgroundCardLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.primary.withValues(alpha: 0.4) : AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : active ? Icons.play_circle_outline : Icons.radio_button_unchecked,
              color: done || active ? AppColors.primary : AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: active || done ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

class _SimuladorCard extends StatelessWidget {
  const _SimuladorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rocket_launch_outlined, color: AppColors.primary, size: 32),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('+100 XP', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Simulador de Mercado', style: AppTextStyles.titleMedium.copyWith(fontSize: 22)),
          const SizedBox(height: 12),
          Text(
            'Analise o gráfico de PETR4 e preveja a tendência dos próximos 5 minutos. Desenvolva seu instinto de trader.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.6, fontSize: 15),
          ),
          const SizedBox(height: 16),
          _StatRow(icon: Icons.bar_chart, label: 'Nível: Intermediário'),
          const SizedBox(height: 10),
          _StatRow(icon: Icons.timer_outlined, label: 'Duração: ~10 minutos'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go(AppRoutes.games),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('COMEÇAR PRÁTICA', style: AppTextStyles.bodySmall.copyWith(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesafioAtivoCard extends StatelessWidget {
  final Challenge challenge;
  const _DesafioAtivoCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.yellowHighlight.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.yellowHighlight.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_outlined, color: AppColors.yellowHighlight, size: 32),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.yellowHighlight.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('+${challenge.points} XP', style: AppTextStyles.bodySmall.copyWith(color: AppColors.yellowHighlight, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.flash_on, color: AppColors.yellowHighlight, size: 14),
              const SizedBox(width: 5),
              Text('DESAFIO ATIVO', style: AppTextStyles.bodySmall.copyWith(color: AppColors.yellowHighlight, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(challenge.title, style: AppTextStyles.highlightTitle.copyWith(fontSize: 24)),
          const SizedBox(height: 12),
          Text(
            challenge.description,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.6, fontSize: 15),
          ),
          const SizedBox(height: 16),
          _StatRow(icon: Icons.access_time_outlined, label: 'Prazo: Hoje às 23:59'),
          const Spacer(),
          Row(
            children: [
              SizedBox(
                width: 76,
                height: 28,
                child: Stack(
                  children: [
                    _FriendAvatar(offset: 0),
                    _FriendAvatar(offset: 24),
                    _FriendBubble(offset: 48, count: 12),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text('14 amigos concluíram', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 14)),
      ],
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final double offset;
  const _FriendAvatar({required this.offset});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: AppColors.backgroundCardLight, shape: BoxShape.circle, border: Border.all(color: AppColors.backgroundCard, width: 2)),
        child: const Icon(Icons.person, color: AppColors.primary, size: 14),
      ),
    );
  }
}

class _FriendBubble extends StatelessWidget {
  final double offset;
  final int count;
  const _FriendBubble({required this.offset, required this.count});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: AppColors.backgroundCardLight, shape: BoxShape.circle, border: Border.all(color: AppColors.backgroundCard, width: 2)),
        child: Center(child: Text('+$count', style: const TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold))),
      ),
    );
  }
}

// ─── Right column ─────────────────────────────────────────────────────────────

class _RightColumn extends StatelessWidget {
  final String league;
  final dynamic user;
  final List<UserProfile> rankingEntries;
  final RankingState rankingState;

  const _RightColumn({
    required this.league,
    required this.user,
    required this.rankingEntries,
    required this.rankingState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: 'SEUS AMIGOS', action: _leagueLabel(league), actionColor: AppColors.primary),
        const SizedBox(height: 12),
        Expanded(
          child: _RankingCard(
            user: user,
            entries: rankingEntries,
            allRanking: rankingState is RankingLoaded ? (rankingState as RankingLoaded).globalRanking : [],
            isLoading: rankingState is RankingLoading,
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'MERCADO', action: 'VER TUDO', onTap: () => context.go(AppRoutes.news)),
        const SizedBox(height: 12),
        _NewsCard(tag: 'ECONOMIA', tagColor: AppColors.primary, time: '15 min', title: 'IPCA de Outubro sobe 0.54% e supera expectativas'),
        const SizedBox(height: 10),
        _NewsCard(tag: 'AÇÕES', tagColor: AppColors.textMuted, time: '42 min', title: 'Ibovespa abre em alta com otimismo no exterior'),
      ],
    );
  }

  String _leagueLabel(String l) {
    switch (l.toLowerCase()) {
      case 'ouro': return 'LIGA OURO';
      case 'prata': return 'LIGA PRATA';
      case 'elite': return 'LIGA ELITE';
      default: return 'LIGA BRONZE';
    }
  }
}

class _RankingCard extends StatelessWidget {
  final dynamic user;
  final List<UserProfile> entries;
  final List<UserProfile> allRanking;
  final bool isLoading;

  const _RankingCard({required this.user, required this.entries, required this.allRanking, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          if (isLoading)
            const Expanded(child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))))
          else if (entries.isEmpty)
            Expanded(
              child: Center(child: Text('Sem dados.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...entries.map((p) {
                    final idx = allRanking.indexWhere((u) => u.id == p.id);
                    final pos = idx >= 0 ? idx + 1 : 0;
                    final isMe = p.id == user?.id;
                    return _RankingRow(pos: pos, profile: p, isCurrentUser: isMe);
                  }),
                  const Spacer(),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go(AppRoutes.ranking),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.cardBorder),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('VER RANKING COMPLETO', style: AppTextStyles.bodySmall.copyWith(fontSize: 10, letterSpacing: 0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int pos;
  final UserProfile profile;
  final bool isCurrentUser;

  const _RankingRow({required this.pos, required this.profile, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isCurrentUser ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          SizedBox(width: 26, child: Text('$pos.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 15))),
          const SizedBox(width: 10),
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isCurrentUser ? AppColors.primary.withValues(alpha: 0.2) : AppColors.backgroundCardLight,
              shape: BoxShape.circle,
              border: isCurrentUser ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                ? ClipOval(child: Image.network(profile.photoUrl!, width: 42, height: 42, fit: BoxFit.cover))
                : Icon(Icons.person, color: isCurrentUser ? AppColors.primary : AppColors.textSecondary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCurrentUser ? 'Você' : profile.name,
              style: AppTextStyles.bodySmall.copyWith(
                color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${profile.xp} XP', style: AppTextStyles.bodySmall.copyWith(color: isCurrentUser ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final String time;
  final String title;

  const _NewsCard({required this.tag, required this.tagColor, required this.time, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tag, style: AppTextStyles.bodySmall.copyWith(color: tagColor, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.bold)),
              Text(time, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, height: 1.5)),
        ],
      ),
    );
  }
}

// ─── Shared ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final Color? actionColor;
  final VoidCallback? onTap;

  const _SectionHeader({required this.title, this.action, this.actionColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2)),
        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: Text(action!, style: AppTextStyles.bodySmall.copyWith(color: actionColor ?? AppColors.primary, fontSize: 11, letterSpacing: 0.8)),
          ),
      ],
    );
  }
}

// ─── Mobile ───────────────────────────────────────────────────────────────────

class _MobileHome extends StatelessWidget {
  final dynamic user;
  final String firstName;
  final Challenge activeChallenge;

  const _MobileHome({required this.user, required this.firstName, required this.activeChallenge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(user: user, firstName: firstName, subtitle: user?.subtitle ?? 'Investidor Iniciante'),
              const SizedBox(height: 12),
              Container(width: 48, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),
              ChallengeCard(challenge: activeChallenge),
              const SizedBox(height: 32),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
                children: [
                  PilarCard(icon: Icons.rocket_launch, title: 'Praticar', description: 'Simulador de mercado', onTap: () => context.go(AppRoutes.games)),
                  PilarCard(icon: Icons.school, title: 'Aprender', description: 'Trilha de aprendizado', onTap: () => context.go(AppRoutes.content)),
                  PilarCard(icon: Icons.track_changes, title: 'Metas', description: 'Acompanhe seus objetivos', onTap: () => context.go(AppRoutes.missions)),
                  PilarCard(icon: Icons.newspaper, title: 'Notícias', description: 'Últimas do mercado', onTap: () => context.go(AppRoutes.news)),
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
