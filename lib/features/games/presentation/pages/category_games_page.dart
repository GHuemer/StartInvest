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
      final bool matchesSearch = quiz.title.toLowerCase().contains(_searchQuery.toLowerCase());
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
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
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
                    const Text('Filtros aplicados:', 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('• Jogos $difficultyName', 
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                Text('${quizzes.length} resultados', 
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: quizzes.isEmpty
                ? const Center(
                    child: Text('Nenhum jogo encontrado', 
                      style: TextStyle(color: Colors.white54, fontSize: 16)))
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Aqui está a mágica que abre a página do quiz!
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuizPage(quiz: quiz)),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quiz.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}