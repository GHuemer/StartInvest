import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/quiz_data.dart';
import '../../domain/entities/quiz_question.dart';
import 'quiz_page.dart';

class CategoryGamesPage extends StatefulWidget {
  final QuizDifficulty difficulty;

  const CategoryGamesPage({super.key, required this.difficulty});

  @override
  State<CategoryGamesPage> createState() => _CategoryGamesPageState();
}

class _CategoryGamesPageState extends State<CategoryGamesPage> {
  String _searchQuery = '';

  String _getDifficultyName(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.conservative:
        return 'Conservadores';
      case QuizDifficulty.moderate:
        return 'Moderados';
      case QuizDifficulty.aggressive:
        return 'Agressivos';
    }
  }

  @override
  Widget build(BuildContext context) {
    final difficultyName = _getDifficultyName(widget.difficulty);

    // Filtragem direta para evitar problemas de estado
    final List<Quiz> quizzes = allQuizzes.where((quiz) {
      final bool matchesSearch = quiz.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final bool matchesDifficulty = quiz.difficulty == widget.difficulty;
      return matchesSearch && matchesDifficulty;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Jogos', style: AppTextStyles.headlineLarge),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ex: Introdução a criptomoedas',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros aplicados:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '• Jogos $difficultyName',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${quizzes.length} resultados',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: quizzes.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum jogo encontrado',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
                      return _QuizListItem(quiz: quiz);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuizListItem extends StatelessWidget {
  final Quiz quiz;
  const _QuizListItem({required this.quiz});

  IconData _getIconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('cripto')) return Icons.currency_bitcoin;
    if (t.contains('ação') || t.contains('ações')) return Icons.trending_up;
    if (t.contains('fii') || t.contains('imobiliário')) return Icons.apartment;
    if (t.contains('tesouro') || t.contains('renda fixa'))
      return Icons.account_balance;
    if (t.contains('etf') || t.contains('índice')) return Icons.pie_chart;
    if (t.contains('fundo')) return Icons.donut_large;
    return Icons.videogame_asset;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuizPage(quiz: quiz)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForTitle(quiz.title),
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Tag de Tipo do Jogo (Quiz)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                          child: const Text(
                            'QUIZ',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Informação Extra (Qtd de perguntas)
                        Icon(
                          Icons.help_outline,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${quiz.questions.length} perguntas',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
