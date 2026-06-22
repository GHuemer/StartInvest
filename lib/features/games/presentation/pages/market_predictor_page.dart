import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/games_bloc.dart';
import '../widgets/market_predictor_game.dart';

class MarketPredictorPage extends StatelessWidget {
  final String difficulty;

  const MarketPredictorPage({
    super.key,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<GamesBloc, GamesState>(
      listenWhen: (_, state) => state is GamesError,
      listener: (context, state) {
        if (state is GamesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.textNegative,
            ),
          );
        }
      },
      child: BlocBuilder<GamesBloc, GamesState>(
        builder: (context, state) {
          if (state is GamesInitial || state is GameLoading) {
            context.read<GamesBloc>().add(
                  StartMarketPredictorEvent(difficulty),
                );
            return const Scaffold(
              backgroundColor: AppColors.backgroundDark,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (state is GameStarted || state is QuestionAnswered || state is GameFinished) {
            return MarketPredictorGame(
              difficulty: difficulty,
              state: state,
            );
          }

          return const Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }
}
