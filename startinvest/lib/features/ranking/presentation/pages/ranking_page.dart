import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const BackButton(),
                  const Text('Ranking', style: AppTextStyles.headlineLarge),
                  const Spacer(),
                  CircleAvatar(radius: 18, backgroundColor: AppColors.backgroundCard, child: const Icon(Icons.person, size: 18, color: AppColors.textSecondary)),
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
              child: TabBarView(
                controller: _tabController,
                children: [_buildFriendsTab(), _buildFriendsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        _buildMyPosition(),
        const SizedBox(height: 16),
        _buildFriendsList(),
        const SizedBox(height: 16),
        _buildLeague(),
      ],
    );
  }

  Widget _buildMyPosition() {
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
                const Text('#12 Gabriel', style: AppTextStyles.headlineMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const CircleAvatar(radius: 24, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: AppColors.white)),
              const SizedBox(height: 4),
              const Text('2.781 pontos', style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    final friends = [
      ('João', '5.567', '🥇', 1),
      ('Pedro', '5.430', '🥈', 2),
      ('Ana', '4.002', '🥉', 3),
      ('Maria', '3.670', '4°', 4),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Seus amigos', style: AppTextStyles.titleLarge),
              const Icon(Icons.person_add_outlined, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 12),
          ...friends.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(f.$3, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    CircleAvatar(radius: 18, backgroundColor: AppColors.backgroundCardLight, child: const Icon(Icons.person, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(f.$1, style: AppTextStyles.titleMedium)),
                    Text('${f.$2} pontos', style: AppTextStyles.bodyMedium),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLeague() {
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
              const Icon(Icons.emoji_events, color: AppColors.accent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Elite', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 2781 / 3000,
                        minHeight: 8,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('2.781 / 3.000', style: AppTextStyles.bodySmall),
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
