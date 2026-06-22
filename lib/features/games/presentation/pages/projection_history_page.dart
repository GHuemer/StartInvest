import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../domain/entities/simulation_result.dart';
import '../bloc/projection/projection_bloc.dart';
import '../bloc/projection/projection_event.dart';
import '../bloc/projection/projection_state.dart';
import 'projection_result_page.dart';

class ProjectionHistoryPage extends StatefulWidget {
  const ProjectionHistoryPage({super.key});

  @override
  State<ProjectionHistoryPage> createState() => _ProjectionHistoryPageState();
}

class _ProjectionHistoryPageState extends State<ProjectionHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectionBloc>().add(const LoadProjectionHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text(
          'Histórico de Simulações',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: BlocBuilder<ProjectionBloc, ProjectionState>(
        builder: (context, state) {
          if (state is ProjectionHistoryLoaded) {
            if (state.history.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.white24),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma simulação salva ainda.\nRode o projetor para começar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              itemCount: state.history.length,
              itemBuilder: (context, index) => _HistoryCard(
                result: state.history[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProjectionResultPage(result: state.history[index]),
                  ),
                ),
              ),
            );
          }

          if (state is ProjectionError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.textNegative),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final SimulationResult result;
  final VoidCallback onTap;

  const _HistoryCard({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat("dd/MM/yyyy 'às' HH:mm");
    final isPositive = result.totalGainPercent >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart,
                        color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      result.periodLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  '${isPositive ? '+' : ''}${result.totalGainPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isPositive
                        ? AppColors.textPositive
                        : AppColors.textNegative,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fmt.format(result.totalInvested),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const Icon(Icons.arrow_forward,
                    color: Colors.white38, size: 14),
                Text(
                  fmt.format(result.totalProjected),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: result.assets
                  .map((a) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          a.ticker,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ))
                  .toList(),
            ),
            if (result.createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                dateFmt.format(result.createdAt!),
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
