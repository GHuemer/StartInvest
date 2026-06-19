import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/ranking_cubit.dart';
import '../bloc/ranking_state.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/entities/league_info.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<RankingCubit>().loadRankings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddFriendDialog() {
    final TextEditingController controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, right: 12),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adicionar Amigo',
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Digite o nome de usuário para enviar um convite de amizade.',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Nome de usuário',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.backgroundDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.alternate_email, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final username = controller.text.trim();
                                if (username.isEmpty) return;

                                setState(() => isLoading = true);

                                final result = await context.read<RankingCubit>().addFriendByUsername(username);

                                if (!context.mounted) return;

                                result.fold(
                                  (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(error),
                                        backgroundColor: AppColors.textNegative,
                                      ),
                                    );
                                  },
                                  (_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Amigo adicionado com sucesso!'),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                                );

                                setState(() => isLoading = false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Enviar Convite', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              // Botão X Vermelho
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.textNegative,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;

        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const Text('Ranking', style: AppTextStyles.headlineLarge),
                      const Spacer(),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.backgroundCard,
                        child: ClipOval(
                          child: user?.photoUrl != null
                              ? Image.network(user!.photoUrl!, fit: BoxFit.cover)
                              : const Icon(Icons.person, size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(24)),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(color: AppColors.backgroundCardLight, borderRadius: BorderRadius.circular(24)),
                      labelColor: AppColors.white,
                      unselectedLabelColor: AppColors.textMuted,
                      tabs: const [Tab(text: 'Amigos'), Tab(text: 'Global')],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<RankingCubit, RankingState>(
                    builder: (context, state) {
                      if (state is RankingLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is RankingError) {
                        return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
                      }
                      if (state is RankingLoaded) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRankingTab(isGlobal: false, user: user, ranking: state.friendsRanking),
                            _buildRankingTab(isGlobal: true, user: user, ranking: state.globalRanking),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankingTab({required bool isGlobal, required List<UserProfile> ranking, AppUser? user}) {
    final userIndex = ranking.indexWhere((p) => p.id == user?.id);
    final userInRanking = userIndex != -1 ? ranking[userIndex] : null;
    
    // Se não estiver no ranking (ex: fora do top 20), usamos os dados do Auth
    final displayXp = userInRanking?.xp ?? user?.xp ?? 0;
    final displayPosition = userIndex != -1 ? '#${userIndex + 1}' : (isGlobal ? '20+' : '#1');

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        _buildMyPosition(user: user, xp: displayXp, position: displayPosition),
        const SizedBox(height: 16),
        _buildFriendsList(isGlobal: isGlobal, ranking: ranking, currentUserId: user?.id),
        const SizedBox(height: 16),
        _buildLeague(user: user, xp: displayXp),
      ],
    );
  }

  Widget _buildMyPosition({AppUser? user, required int xp, required String position}) {
    final firstName = user?.name.split(' ').first ?? 'Você';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sua posição', style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text('$position $firstName', style: AppTextStyles.headlineMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: ClipOval(
                  child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                      ? Image.network(user.photoUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.person, color: AppColors.white),
                ),
              ),
              const SizedBox(height: 4),
              Text('$xp pontos', style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList({required bool isGlobal, required List<UserProfile> ranking, String? currentUserId}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isGlobal ? 'Top Global' : 'Seus amigos', style: AppTextStyles.titleLarge),
              if (!isGlobal)
                IconButton(
                  onPressed: _showAddFriendDialog,
                  icon: const Icon(Icons.person_add_outlined, color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (ranking.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Nenhum dado disponível', style: AppTextStyles.bodyMedium)),
            )
          else
            ...ranking.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isCurrentUser = item.id == currentUserId;

              String rankIcon = '${index + 1}°';
              if (index == 0) rankIcon = '🥇';
              if (index == 1) rankIcon = '🥈';
              if (index == 2) rankIcon = '🥉';

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCurrentUser ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 30, child: Text(rankIcon, style: const TextStyle(fontSize: 20))),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.backgroundCardLight,
                      child: item.photoUrl != null && item.photoUrl!.isNotEmpty
                          ? ClipOval(child: Image.network(item.photoUrl!, fit: BoxFit.cover, width: 36, height: 36))
                          : const Icon(Icons.person, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isCurrentUser ? '${item.name} (Você)' : item.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isCurrentUser ? AppColors.primary : Colors.white,
                          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    Text('${item.xp} pontos', style: AppTextStyles.bodyMedium),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLeague({AppUser? user, required int xp}) {
    final league = LeagueInfo.getLeagueByXp(xp);
    
    // Calcula o progresso para a próxima liga
    final currentLeagueIndex = LeagueInfo.leagues.indexOf(league);
    int nextMilestone = xp;
    double progress = 1.0;
    
    if (currentLeagueIndex < LeagueInfo.leagues.length - 1) {
      final nextLeague = LeagueInfo.leagues[currentLeagueIndex + 1];
      nextMilestone = nextLeague.minXp;
      final currentMilestone = league.minXp;
      progress = ((xp - currentMilestone) / (nextMilestone - currentMilestone)).clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Liga', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(league.icon, color: league.color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(league.name.toUpperCase(), style: AppTextStyles.titleMedium),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation(league.color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentLeagueIndex < LeagueInfo.leagues.length - 1 
                        ? '$xp / $nextMilestone para ${LeagueInfo.leagues[currentLeagueIndex + 1].name}'
                        : 'Nível Máximo atingido!', 
                      style: AppTextStyles.bodySmall
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
