import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/game_session.dart';
import '../bloc/games_bloc.dart';

class MarketPredictorGame extends StatefulWidget {
  final String difficulty;
  final GamesState state;

  const MarketPredictorGame({
    super.key,
    required this.difficulty,
    required this.state,
  });

  @override
  State<MarketPredictorGame> createState() => _MarketPredictorGameState();
}

class _MarketPredictorGameState extends State<MarketPredictorGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _answered = false;
  bool? _lastAnswer;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onAnswerSelected(bool answer) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _lastAnswer = answer;
    });

    context.read<GamesBloc>().add(AnswerQuestionEvent(answer));
    _animationController.forward();
  }

  void _onNextQuestion() {
    final state = context.read<GamesBloc>().state;

    if (state is QuestionAnswered) {
      final session = state.session;
      final isLastQuestion =
          session.currentQuestionIndex + 1 == session.questions.length;

      if (isLastQuestion) {
        context.read<GamesBloc>().add(const FinishGameEvent());
      } else {
        setState(() {
          _answered = false;
          _lastAnswer = null;
          _isCorrect = null;
        });
        _animationController.reset();
        context.read<GamesBloc>().add(const NextQuestionEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GamesBloc, GamesState>(
      listener: (context, state) {
        if (state is GameFinished) {
          _showResultsDialog(context, state);
        }
      },
      builder: (context, state) {
        GameSession? session;
        bool? isCorrect;
        int? pointsEarned;

        if (state is GameStarted) {
          session = state.session;
          _isCorrect = null;
        } else if (state is QuestionAnswered) {
          session = state.session;
          isCorrect = state.isCorrect;
          pointsEarned = state.pointsEarned;
          _isCorrect = isCorrect;
        }

        if (session == null) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentQuestion = session.questions[session.currentQuestionIndex];

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundCard,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Market Predictor - ${widget.difficulty.toUpperCase()}',
              style: AppTextStyles.headlineMedium,
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Progress bar
                _ProgressIndicator(
                  current: session.currentQuestionIndex + 1,
                  total: session.questions.length,
                ),
                const SizedBox(height: 32),

                // Streak and points
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      label: 'Streak',
                      value: session.streak.toString(),
                      icon: '🔥',
                    ),
                    _StatCard(
                      label: 'Pontos',
                      value: session.totalPoints.toString(),
                      icon: '⭐',
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Question card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Questão ${session.currentQuestionIndex + 1}',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentQuestion.company,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentQuestion.story,
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Answer buttons
                if (!_answered)
                  Row(
                    children: [
                      Expanded(
                        child: _AnswerButton(
                          label: 'Ação Sobe\n📈',
                          onPressed: () => _onAnswerSelected(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _AnswerButton(
                          label: 'Ação Desce\n📉',
                          onPressed: () => _onAnswerSelected(false),
                        ),
                      ),
                    ],
                  )
                else if (isCorrect != null)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.textNegative.withOpacity(0.1),
                          border: Border.all(
                            color: isCorrect
                                ? AppColors.primary
                                : AppColors.textNegative,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              isCorrect ? '✓' : '✗',
                              style: TextStyle(
                                fontSize: 32,
                                color: isCorrect
                                    ? AppColors.primary
                                    : AppColors.textNegative,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCorrect
                                        ? 'Resposta Correta!'
                                        : 'Resposta Errada!',
                                    style: AppTextStyles.titleLarge.copyWith(
                                      color: isCorrect
                                          ? AppColors.primary
                                          : AppColors.textNegative,
                                    ),
                                  ),
                                  if (isCorrect && pointsEarned != null)
                                    Text(
                                      '+$pointsEarned pontos',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  if (!isCorrect)
                                    Text(
                                      'Resposta correta: ${currentQuestion.correctAnswer ? 'Sobe' : 'Desce'}',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (currentQuestion.explanation != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDark,
                            border: Border.all(color: AppColors.cardBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentQuestion.explanation!,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _onNextQuestion,
                          child: Text(
                            session.currentQuestionIndex + 1 ==
                                    session.questions.length
                                ? 'Ver Resultados'
                                : 'Próxima Questão',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.textBlack,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResultsDialog(BuildContext context, GameFinished state) {
    final result = state.result;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Jogo Finalizado!', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 24),
              _ResultRow(
                label: 'Pontuação',
                value: '${result.totalPoints} pts',
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              _ResultRow(
                label: 'Acertos',
                value: '${result.correctAnswers}/${result.totalQuestions}',
                color: AppColors.textPositive,
              ),
              const SizedBox(height: 8),
              _ResultRow(
                label: 'Precisão',
                value: '${result.accuracy.toStringAsFixed(1)}%',
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              _ResultRow(
                label: 'Melhor Streak',
                value: '${result.bestStreak}🔥',
                color: AppColors.yellowHighlight,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.go('/games');
                  },
                  child: const Text(
                    'Voltar aos Jogos',
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyLarge),
          Text(value, style: AppTextStyles.titleLarge.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progresso', style: AppTextStyles.titleMedium),
            Text('$current/$total', style: AppTextStyles.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 8,
            backgroundColor: AppColors.cardBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _AnswerButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
