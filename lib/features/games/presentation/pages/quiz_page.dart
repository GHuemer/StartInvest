import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/profile_cubit.dart';
import '../../domain/entities/quiz_question.dart';
import '../../../../core/di/injection.dart';
import 'package:flutter/services.dart';
import '../../../missions/data/datasources/missions_remote_datasource.dart';

class QuizPage extends StatefulWidget {
  final Quiz quiz;
  const QuizPage({super.key, required this.quiz});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  bool _isFinished = false;
  bool _alreadyEarnedPoints = false;

  void _answerQuestion(int index) {
    if (_isAnswered) return;
    
    final isCorrect = index == widget.quiz.questions[_currentQuestionIndex].correctAnswerIndex;
    
    if (isCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.vibrate();
    }

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    HapticFeedback.mediumImpact();
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  int _calculateXP() {
    final correct = _score;
    switch (widget.quiz.difficulty) {
      case QuizDifficulty.conservative:
        if (correct < 2) return 0;
        if (correct == 2) return 10;
        if (correct == 3) return 15;
        if (correct == 4) return 20;
        return 25;
      case QuizDifficulty.moderate:
        if (correct < 3) return -10;
        if (correct == 3) return 30;
        if (correct == 4) return 40;
        return 50;
      case QuizDifficulty.aggressive:
        if (correct < 4) return -30;
        if (correct == 4) return 60;
        return 100;
    }
  }

  Future<void> _finishQuiz() async {
    final xpGained = _calculateXP();
    final authState = context.read<AuthBloc>().state;
    
    if (authState is AuthAuthenticated) {
      final missionsDataSource = getIt<MissionsRemoteDataSource>();
      final quizId = 'quiz_${widget.quiz.title.replaceAll(' ', '_').toLowerCase()}';
      
      final success = await missionsDataSource.completeMission(quizId, xpGained);
      
      setState(() {
        _isFinished = true;
        _alreadyEarnedPoints = !success && xpGained > 0;
      });

      if (success) {
        if (mounted) {
          context.read<ProfileCubit>().loadProfile(force: true);
        }
      }
    } else {
      setState(() => _isFinished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildResultScreen();
    }

    final question = widget.quiz.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => _showExitDialog(),
                  ),
                  Text(
                    'Pergunta ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.backgroundCard,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.question,
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 32),
                    ...List.generate(
                      question.options.length,
                      (index) => _buildOption(index, question),
                    ),
                  ],
                ),
              ),
            ),
            if (_isAnswered)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentQuestionIndex == widget.quiz.questions.length - 1 ? 'Finalizar' : 'Próxima',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, QuizQuestion question) {
    bool isCorrect = index == question.correctAnswerIndex;
    bool isSelected = index == _selectedAnswerIndex;
    
    Color borderColor = Colors.transparent;
    Color bgColor = AppColors.backgroundCard;
    
    if (_isAnswered) {
      if (isCorrect) {
        borderColor = AppColors.primary;
        bgColor = AppColors.primary.withOpacity(0.1);
      } else if (isSelected) {
        borderColor = AppColors.textNegative;
        bgColor = AppColors.textNegative.withOpacity(0.1);
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () => _answerQuestion(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected || (_isAnswered && isCorrect) ? AppColors.primary : AppColors.textMuted),
                color: isSelected || (_isAnswered && isCorrect) ? AppColors.primary : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: isSelected || (_isAnswered && isCorrect) ? Colors.white : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                question.options[index],
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final xpGained = _calculateXP();
    final isWin = xpGained > 0;
    final isNeutral = xpGained == 0;
    
    String title = 'Parabéns!';
    IconData icon = Icons.emoji_events;
    Color iconColor = AppColors.accent;

    if (isNeutral) {
      title = 'Bom esforço!';
      icon = Icons.sentiment_satisfied;
      iconColor = AppColors.primary;
    } else if (!isWin) {
      title = 'Não foi desta vez';
      icon = Icons.sentiment_very_dissatisfied;
      iconColor = AppColors.textNegative;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 100),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Pontuação Final: $_score/${widget.quiz.questions.length}',
                style: AppTextStyles.titleLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _alreadyEarnedPoints 
                      ? Colors.orange.withOpacity(0.2)
                      : (xpGained >= 0 ? AppColors.primary.withOpacity(0.2) : AppColors.textNegative.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      _alreadyEarnedPoints 
                          ? '0 pontos' 
                          : (xpGained >= 0 ? '+ $xpGained pontos' : '$xpGained pontos'),
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: _alreadyEarnedPoints ? Colors.orange : (xpGained >= 0 ? AppColors.primary : AppColors.textNegative),
                      ),
                    ),
                    if (_alreadyEarnedPoints)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Você já resgatou os pontos deste quiz!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.orange, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Fechar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Tem certeza?', style: TextStyle(color: Colors.white)),
        content: const Text('Seu progresso neste quiz será perdido.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Fecha o dialog
            child: const Text('Ficar', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o dialog
              Navigator.pop(this.context); // Fecha a tela do quiz usando o contexto correto do StatefulWidget
            },
            child: const Text('Sair', style: TextStyle(color: AppColors.textNegative)),
          ),
        ],
      ),
    );
  }
}
