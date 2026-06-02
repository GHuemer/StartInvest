import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/missions_cubit.dart';
import '../bloc/missions_state.dart';
import '../widgets/mission_card.dart';
import '../../domain/entities/mission_entity.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_back_button.dart';

class MissionsPage extends StatelessWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MissionsCubit>()..init(),
      child: const MissionsView(),
    );
  }
}

class MissionsView extends StatelessWidget {
  const MissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<MissionsCubit, MissionsState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        const AppBackButton(),
                        const Text(
                          'Metas',
                          style: AppTextStyles.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progresso: ${state.completedCount}/${state.allMissions.length}',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: state.totalProgress,
                            minHeight: 8,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Tudo',
                            isSelected: state.activeFilter == MissionCategory.all,
                            onTap: () => context.read<MissionsCubit>().filterMissions(MissionCategory.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Aprendizado',
                            isSelected: state.activeFilter == MissionCategory.learning,
                            onTap: () => context.read<MissionsCubit>().filterMissions(MissionCategory.learning),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Prática',
                            isSelected: state.activeFilter == MissionCategory.practice,
                            onTap: () => context.read<MissionsCubit>().filterMissions(MissionCategory.practice),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: state.filteredMissions.isEmpty
                      ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: Text('Nenhuma missão encontrada.')),
                        )
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9, // Ajustado para suportar a barra de progresso sem quebrar o layout
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => MissionCard(mission: state.filteredMissions[i]),
                            childCount: state.filteredMissions.length,
                          ),
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Restaurado padding original
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(20), // Restaurado radius original
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
